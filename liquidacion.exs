defmodule Liquidacion do
  @moduledoc """
  Módulo encargado de calcular los valores económicos, bonificaciones,
  descuentos por alquiler y el neto a pagar por cada confeccionista.
  """

  @doc """
  calcula la liquidacion de los confeccionistas, y devuelve una lista de maps,
  """
  def liquidar_todos(lotes, confeccionistas) do
    lotes_por_confeccionista = Enum.group_by(lotes, & &1.confeccionista)  # se agruparon los lotes por confeccionistas, para facilitar los calculos

    Enum.map(confeccionistas, fn confeccionista ->

      lotes = Map.get(lotes_por_confeccionista, confeccionista.codigo, [])  # se obtienen los lotes del confeccionista actual, si no tiene lotes, se asigna una lista vacia, usando el default, de Map.get
      liquidar_confeccionista(confeccionista, lotes)
    end)
  end

  @doc """
  Calcula la liquidación individual de un confeccionista.
  """
  def liquidar_confeccionista(confeccionista, lotes) do
    suma_lotes = calcular_suma_lotes(lotes)
    bono_prod = calcular_bonificacion_productividad(lotes)
    dias_trabajados = calcular_dias_trabajados(lotes)
    descuento_alquiler = calcular_alquiler(confeccionista, dias_trabajados)

    neto = suma_lotes + bono_prod - descuento_alquiler

    %{
      codigo: confeccionista.codigo,
      nombre: Map.get(confeccionista, :nombre, "Confeccionista #{confeccionista.codigo}"),
      suma_lotes: suma_lotes,
      bonificacion_productividad: bono_prod,
      dias_trabajados: dias_trabajados,
      descuento_alquiler: descuento_alquiler,
      neto: neto
    }
  end


  @doc """
  suma el precio de todos los lotes, y debuelve el total, osea la suma de todos los precios de los lotes
  """
  def calcular_suma_lotes(lotes) do
    lotes
    |> Enum.map(&calcular_valor_lote/1)
    |> Enum.sum()
  end

  @doc """
  calcula el valor de un lote, multiplicando la cantidad de prendas por la tarifa base, y aplicando un factor de ajuste segun el porcentaje de defectos.
  """
  def calcular_valor_lote(lote) do
    valor_base = lote.prendas * ParametrosTaller.tarifa_base_prenda()
    factor = factor_ajuste_defectos(lote.defectos)

    round(valor_base * factor)
  end

  defp factor_ajuste_defectos(defectos) when defectos <= 2.0, do: 1.07
  defp factor_ajuste_defectos(defectos) when defectos <= 5.0, do: 1.00
  defp factor_ajuste_defectos(defectos) when defectos <= 10.0, do: 0.88
  defp factor_ajuste_defectos(_defectos), do: 0.75


  @doc """
  añade 18000 al precio total, cuando el confeccionista consigue mas de 120 prendas en el dia, y devuelve la bonificacion total de, importante, todos los dias.
  """
  def calcular_bonificacion_productividad(lotes) do
    lotes
    |> Enum.group_by(& &1.dia)
    |> Enum.reduce(0, fn {_dia, lotes_del_dia}, acumulador_bono ->
      total_prendas_dia = Enum.sum_by(lotes_del_dia, & &1.prendas)

      if total_prendas_dia >= ParametrosTaller.prendas_diarias_bonificacion() do
        acumulador_bono + ParametrosTaller.bonificacion_diaria()
      else
        acumulador_bono
      end
    end)
  end


  @doc """
  calcula la cantidad de dias trabajados, tomando los dias, de los lotes, y eliminando los duplicados con uniq.
  """
  def calcular_dias_trabajados(lotes) do
    lotes
    |> Enum.map(& &1.dia)
    |> Enum.uniq()
    |> length()
  end

  @doc """
  calcula el alquiler total, multiplicando los dias trabajados por el alquiler diario,
  si el confeccionista usa maquina, si no, devuelve 0.
  """
  def calcular_alquiler(confeccionista, dias_trabajados) do
    usa_maquina? =
      Map.get(confeccionista, :maquina, false) or
      Map.get(confeccionista, :utiliza_maquina, false) or
      Map.get(confeccionista, :usa_maquina, false)

    if usa_maquina? do
      dias_trabajados * ParametrosTaller.alquiler_maquina_dia()
    else
      0
    end
  end
end
