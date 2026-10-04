defmodule Reportes do
  @moduledoc """
  Módulo para la generación de reportes del taller de confección.
  """

  @doc "R1: Lotes rechazados con su motivo y cantidad por cada motivo"
  def lotes_rechazados(lotes_rechazados) do
    conteo_motivos =
      Enum.reduce(lotes_rechazados, %{}, fn registro, mapa_conteo ->
        motivo = registro.motivo
        cantidad_actual = Map.get(mapa_conteo, motivo, 0)
        Map.put(mapa_conteo, motivo, cantidad_actual + 1)
      end)

    %{
      lotes_rechazados: lotes_rechazados,
      conteo_motivos: conteo_motivos
    }
  end

  @doc "R2: Prendas producidas por día y cumplimiento de meta (600)"
  def produccion_diaria(lotes_validos) do
    meta = ParametrosTaller.meta_diaria_taller()

    dias_reporte =
      Enum.map(1..6, fn dia_actual ->
        lotes_del_dia = Enum.filter(lotes_validos, fn lote -> lote.dia == dia_actual end)
        prendas_lotes = Enum.map(lotes_del_dia, fn lote -> lote.prendas end)
        total_prendas = Enum.sum(prendas_lotes)

        %{
          dia: dia_actual,
          total_prendas: total_prendas,
          alcanzo_meta: total_prendas >= meta
        }
      end)

    alcanzo_todos = Enum.all?(dias_reporte, fn d -> d.alcanzo_meta end)
    alcanzo_al_menos_uno = Enum.any?(dias_reporte, fn d -> d.alcanzo_meta end)

    %{
      detalle_dias: dias_reporte,
      alcanzo_meta_todos_los_dias: alcanzo_todos,
      alcanzo_meta_al_menos_un_dia: alcanzo_al_menos_uno
    }
  end

  @doc "R3: Prendas por línea y productividad por puesto"
  def produccion_por_linea(lotes_validos, lineas) do
    resultado_lineas =
      Enum.map(lineas, fn linea ->
        lotes_linea = Enum.filter(lotes_validos, fn lote -> lote.linea == linea.id end)
        prendas_lista = Enum.map(lotes_linea, fn lote -> lote.prendas end)
        total_prendas = Enum.sum(prendas_lista)

        productividad =
          if linea.puestos > 0 do
            total_prendas / linea.puestos
          else
            0.0
          end

        %{
          linea_id: linea.id,
          nombre: linea.nombre,
          puestos: linea.puestos,
          total_prendas: total_prendas,
          productividad: productividad
        }
      end)
    Enum.sort_by(resultado_lineas, fn registro -> registro.productividad end, :desc)
  end

  @doc "R4: Liquidación ordenada de mayor a menor neto"
  def tabla_liquidacion(lotes_validos, confeccionistas) do
    liquidaciones = Liquidacion.liquidar_todos(lotes_validos, confeccionistas)
    liquidaciones_ordenadas = Enum.sort_by(liquidaciones, fn liq -> liq.neto end, :desc)

    {resultado, _indice} =
      Enum.reduce(liquidaciones_ordenadas, {[], 1}, fn liq, {acc_lista, num} ->
        lotes_c = Enum.filter(lotes_validos, fn l -> l.confeccionista == liq.codigo end)
        prendas_c = Enum.map(lotes_c, fn l -> l.prendas end)
        total_prendas = Enum.sum(prendas_c)

        registro_final = %{
          numero: num,
          codigo: liq.codigo,
          nombre: liq.nombre,
          prendas: total_prendas,
          suma_lotes: liq.suma_lotes,
          bonificacion: liq.bonificacion_productividad,
          alquiler: liq.descuento_alquiler,
          neto: liq.neto
        }

        {[registro_final | acc_lista], num + 1}
      end)
    Enum.reverse(resultado)
  end

  @doc "R5: Confeccionista con más prendas por día y de la semana"
  def top_diario(lotes_validos, confeccionistas) do
    detalle_diario =
      Enum.map(1..6, fn dia_actual ->
        lotes_dia = Enum.filter(lotes_validos, fn l -> l.dia == dia_actual end)

        if lotes_dia == [] do
          %{dia: dia_actual, ganadores: [], max_prendas: 0, sin_lotes: true}
        else
          prendas_por_c =
            Enum.map(confeccionistas, fn c ->
              lotes_c_dia = Enum.filter(lotes_dia, fn l -> l.confeccionista == c.codigo end)
              prendas_c = Enum.map(lotes_c_dia, fn l -> l.prendas end)
              %{codigo: c.codigo, prendas: Enum.sum(prendas_c)}
            end)

          max_prendas =
            prendas_por_c
            |> Enum.map(fn registro -> registro.prendas end)
            |> Enum.max()

          ganadores =
            prendas_por_c
            |> Enum.filter(fn r -> r.prendas == max_prendas and r.prendas > 0 end)
            |> Enum.map(fn r -> r.codigo end)

          %{dia: dia_actual, ganadores: ganadores, max_prendas: max_prendas, sin_lotes: false}
        end
      end)

    todos_los_ganadores =
      detalle_diario
      |> Enum.reject(fn d -> d.sin_lotes end)
      |> Enum.flat_map(fn d -> d.ganadores end)

    lideres =
      if todos_los_ganadores == [] do
        []
      else
        conteo_victorias =
          Enum.reduce(todos_los_ganadores, %{}, fn cod, mapa ->
            Map.put(mapa, cod, Map.get(mapa, cod, 0) + 1)
          end)

        max_victorias = Enum.max(Map.values(conteo_victorias))

        Enum.filter(conteo_victorias, fn {_cod, v} -> v == max_victorias end)
      end

    %{
      detalle_diario: detalle_diario,
      lideres_semana: lideres
    }
  end

  @doc "R6: Mejor Calidad (Menor porcentaje de defectos ponderado, min 3 lotes)"
  def mejor_calidad(lotes_validos, confeccionistas) do
    candidatos =
      Enum.reduce(confeccionistas, [], fn c, acumulador ->
        lotes_c = Enum.filter(lotes_validos, fn l -> l.confeccionista == c.codigo end)

        if length(lotes_c) >= 3 do
          sumatoria_defectos_prendas =
            lotes_c
            |> Enum.map(fn l -> l.defectos * l.prendas end)
            |> Enum.sum()

          sumatoria_prendas =
            lotes_c
            |> Enum.map(fn l -> l.prendas end)
            |> Enum.sum()

          porcentaje_ponderado = sumatoria_defectos_prendas / sumatoria_prendas

          registro = %{
            codigo: c.codigo,
            nombre: c.nombre,
            pct_ponderado: porcentaje_ponderado
          }

          [registro | acumulador]
        else
          acumulador
        end
      end)

    if candidatos == [] do
      {:error, "Ningún confeccionista cumple con el mínimo de 3 lotes válidos"}
    else
      mejor = Enum.min_by(candidatos, fn c -> c.pct_ponderado end)
      {:ok, mejor}
    end
  end

  @doc "R7: Total a pagar y costo promedio por prenda válida"
  def costo_promedio(lotes_validos, confeccionistas) do
    liquidaciones = Liquidacion.liquidar_todos(lotes_validos, confeccionistas)

    pagos = Enum.map(liquidaciones, fn liq -> liq.neto end)
    total_pagado = Enum.sum(pagos)

    prendas = Enum.map(lotes_validos, fn lote -> lote.prendas end)
    total_prendas_validas = Enum.sum(prendas)

    if total_prendas_validas > 0 do
      promedio = total_pagado / total_prendas_validas

      %{
        total_pagado: total_pagado,
        total_prendas_validas: total_prendas_validas,
        costo_promedio_prenda: promedio
      }
    else
      %{
        total_pagado: 0,
        total_prendas_validas: 0,
        costo_promedio_prenda: "No se puede calcular (sin prendas válidas)"
      }
    end
  end


  @doc "R8: Confeccionistas que trabajaron en todas las líneas de producción"
  def cobertura_todas_las_lineas(lotes_validos, confeccionistas, lineas) do
    total_lineas_existentes = length(lineas)
    ids_lineas = Enum.map(lineas, fn l -> l.id end)

    cumplen =
      Enum.filter(confeccionistas, fn c ->
        lotes_c = Enum.filter(lotes_validos, fn l -> l.confeccionista == c.codigo end)
        lineas_c = Enum.map(lotes_c, fn l -> l.linea end)
        lineas_unicas = Enum.uniq(lineas_c)
        length(lineas_unicas) == total_lineas_existentes
      end)

    if cumplen == [] do
      {:sin_resultado, "Ningún confeccionista elaboró lotes en todas las líneas."}
    else
      {:ok, cumplen}
    end
  end

  @doc "C.1: Función de Ranking para la parte de Investigación"
  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    liquidaciones_ordenadas =
      Enum.sort_by(liquidaciones, fn liq ->
        case campo do
          :neto -> liq.neto
          :bruto -> liq.suma_lotes
          :prendas -> Map.get(liq, :prendas, 0)
        end
      end, orden)

    Enum.take(liquidaciones_ordenadas, limite)
  end
end
