Code.require_file("datos.exs")
Code.require_file("parametros_taller.exs")
Code.require_file("comprobacion_datos.exs")
Code.require_file("validacion_lotes.exs")
Code.require_file("liquidacion.exs")
Code.require_file("reportes.exs")
Code.require_file("interaccion_usuario.exs")
Code.require_file("util.ex")

defmodule Programa do
  @moduledoc """
  Módulo principal que ejecuta el flujo general del taller de confecciones,
  reportes y demostraciones adicionales (C.1 y C.2).
  """

  def main do
    Util.mostrar_mensaje("==================================================")
    Util.mostrar_mensaje(" SISTEMA DE GESTIÓN DE TALLER DE CONFECCIONES ")
    Util.mostrar_mensaje("==================================================")

    confeccionistas = Datos.confeccionistas()
    lineas = Datos.lineas()
    lotes_base = Datos.lotes()

    lotes_totales =
      case InteraccionUsuario.pedir_lote_adicional() do
        {:ok, lote_nuevo} ->
          Util.mostrar_mensaje("--> Lote adicional ingresado con éxito.")
          lotes_base ++ [lote_nuevo]

        :omitido ->
          Util.mostrar_mensaje("--> Se omitió el ingreso de lotes adicionales.")
          lotes_base

        {:error, :formato_invalido} ->
          Util.mostrar_error("--> Error: El formato del lote ingresado es inválido. Se ignorará.")
          lotes_base
      end

    {validos, rechazados} = ValidacionLotes.validar_todos(lotes_totales, confeccionistas, lineas)

    mostrar_reporte_rechazados(rechazados)
    mostrar_reporte_produccion_diaria(validos)
    mostrar_reporte_lineas(validos, lineas)
    mostrar_reporte_liquidacion(validos, confeccionistas)
    mostrar_reporte_top_diario(validos, confeccionistas)
    mostrar_reporte_calidad(validos, confeccionistas)
    mostrar_reporte_costo_promedio(validos, confeccionistas)
    mostrar_reporte_cobertura(validos, confeccionistas, lineas)

    demostrar_ranking_c1(validos, confeccionistas)

    demostrar_combinacion_c2(validos)

    InteraccionUsuario.consultar_comprobante(validos, confeccionistas)
  end

  # --- Métodos Auxiliares para C.1 y C.2 ---

  defp demostrar_ranking_c1(validos, confeccionistas) do
    Util.mostrar_mensaje("\n==================================================")
    Util.mostrar_mensaje(" C.1: DEMOSTRACIÓN DE RANKING CON KEYWORD LISTS")
    Util.mostrar_mensaje("==================================================")

    liquidaciones = Liquidacion.liquidar_todos(validos, confeccionistas)

    Util.mostrar_mensaje("\n--- Prueba 1: Reportes.ranking(liquidaciones, []) ---")
    imprimir_ranking(Reportes.ranking(liquidaciones, []))

    Util.mostrar_mensaje("\n--- Prueba 2: Reportes.ranking(liquidaciones, campo: :prendas, limite: 3) ---")
    imprimir_ranking(Reportes.ranking(liquidaciones, campo: :prendas, limite: 3))

    Util.mostrar_mensaje("\n--- Prueba 3: Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto) ---")
    imprimir_ranking(Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto))
  end

  defp imprimir_ranking(lista) do
    Enum.each(lista, fn elem ->
      neto = Map.get(elem, :neto, 0)
      suma_lotes = Map.get(elem, :suma_lotes, 0)
      codigo = Map.get(elem, :codigo, "N/A")
      nombre = Map.get(elem, :nombre, "Sin nombre")

      Util.mostrar_mensaje("  [#{codigo}] #{nombre} | Neto: $#{neto} | Bruto (Lotes): $#{suma_lotes}")
    end)
  end

  defp demostrar_combinacion_c2(validos) do
    Util.mostrar_mensaje("\n==================================================")
    Util.mostrar_mensaje(" C.2: COMBINACIÓN DE PRODUCCIÓN CON TALLER ALIADO")
    Util.mostrar_mensaje("==================================================")

    produccion_propia =
      validos
      |> Enum.group_by(& &1.dia)
      |> Enum.map(fn {dia, lotes} -> {dia, Enum.sum(Enum.map(lotes, & &1.prendas))} end)
      |> Enum.into(%{})

    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

    produccion_combinada = Reportes.combinar_produccion_aliado(produccion_propia, taller_aliado)

    Util.mostrar_mensaje("Producción diaria combinada:")
    Enum.each(Enum.sort(produccion_combinada), fn {dia, total} ->
      Util.mostrar_mensaje("  Día #{dia}: #{total} prendas")
    end)
  end

  # --- Métodos Auxiliares de Formateo de Reportes R1-R8 ---

  defp mostrar_reporte_rechazados(rechazados) do
    Util.mostrar_mensaje("\n--- R1: LOTES RECHAZADOS ---")
    reporte = Reportes.lotes_rechazados(rechazados)

    Util.mostrar_mensaje("Total rechazados: #{length(reporte.lotes_rechazados)}")
    Util.mostrar_mensaje("Conteo por motivo:")
    Enum.each(reporte.conteo_motivos, fn {motivo, cant} ->
      Util.mostrar_mensaje("  - #{motivo}: #{cant}")
    end)
  end

  defp mostrar_reporte_produccion_diaria(validos) do
    Util.mostrar_mensaje("\n--- R2: PRODUCCIÓN DIARIA Y META ---")
    reporte = Reportes.produccion_diaria(validos)

    Enum.each(reporte.detalle_dias, fn d ->
      cumplio = if d.alcanzo_meta, do: "SÍ", else: "NO"
      Util.mostrar_mensaje("  Día #{d.dia}: #{d.total_prendas} prendas | Meta alcanzada: #{cumplio}")
    end)

    Util.mostrar_mensaje("¿Alcanzó meta todos los días?: #{if reporte.alcanzo_meta_todos_los_dias, do: "SÍ", else: "NO"}")
  end

  defp mostrar_reporte_lineas(validos, lineas) do
    Util.mostrar_mensaje("\n--- R3: PRODUCCIÓN POR LÍNEA ---")
    Enum.each(Reportes.produccion_por_linea(validos, lineas), fn l ->
      Util.mostrar_mensaje("  #{l.nombre} (#{l.linea_id}): #{l.total_prendas} prendas | Prod/Puesto: #{Util.formater(l.productividad)}")
    end)
  end

  defp mostrar_reporte_liquidacion(validos, confeccionistas) do
    Util.mostrar_mensaje("\n--- R4: TABLA DE LIQUIDACIÓN ---")
    tabla = Reportes.tabla_liquidacion(validos, confeccionistas)

    Enum.each(tabla, fn r ->
      Util.mostrar_mensaje("  #{r.numero}. [#{r.codigo}] #{r.nombre} | Prendas: #{r.prendas} | Neto: $#{r.neto}")
    end)
  end

  defp mostrar_reporte_top_diario(validos, confeccionistas) do
    Util.mostrar_mensaje("\n--- R5: TOP DIARIO Y LÍDERES ---")
    reporte = Reportes.top_diario(validos, confeccionistas)

    Enum.each(reporte.detalle_diario, fn d ->
      ganadores_str = Enum.join(d.ganadores, ", ")
      Util.mostrar_mensaje("  Día #{d.dia}: Max prendas #{d.max_prendas} por [#{ganadores_str}]")
    end)

    lideres = Enum.map(reporte.lideres_semana, fn {cod, v} -> "#{cod} (#{v} victorias)" end)
    Util.mostrar_mensaje("  Líder(es) de la semana: #{Enum.join(lideres, ", ")}")
  end

  defp mostrar_reporte_calidad(validos, confeccionistas) do
    Util.mostrar_mensaje("\n--- R6: MEJOR CALIDAD ---")
    case Reportes.mejor_calidad(validos, confeccionistas) do
      {:ok, mejor} ->
        Util.mostrar_mensaje("  Ganador: #{mejor.nombre} (#{mejor.codigo}) con #{Util.formater(mejor.pct_ponderado)}% de defectos")

      {:error, msg} ->
        Util.mostrar_mensaje("  #{msg}")
    end
  end

  defp mostrar_reporte_costo_promedio(validos, confeccionistas) do
    Util.mostrar_mensaje("\n--- R7: COSTO PROMEDIO POR PRENDA ---")
    res = Reportes.costo_promedio(validos, confeccionistas)
    Util.mostrar_mensaje("  Total pagado: $#{res.total_pagado}")
    Util.mostrar_mensaje("  Prendas válidas: #{res.total_prendas_validas}")
    Util.mostrar_mensaje("  Costo promedio/prenda: $#{Util.formater(res.costo_promedio_prenda)}")
  end

  defp mostrar_reporte_cobertura(validos, confeccionistas, lineas) do
    Util.mostrar_mensaje("\n--- R8: COBERTURA TOTAL DE LÍNEAS ---")
    case Reportes.cobertura_todas_las_lineas(validos, confeccionistas, lineas) do
      {:ok, cumplen} ->
        nombres = Enum.map(cumplen, & &1.nombre)
        Util.mostrar_mensaje("  Confeccionistas en todas las líneas: #{Enum.join(nombres, ", ")}")

      {:sin_resultado, msg} ->
        Util.mostrar_mensaje("  #{msg}")
    end
  end
end

Programa.main()
