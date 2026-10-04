defmodule ValidacionLotes do
  @moduledoc """
  Módulo encargado de la validación sintáctica y reglas de negocio para los lotes.
  """

  @doc """
  Valida la totalidad de los lotes almacenados en el módulo Datos.
  """
  def validar_lotes do
    lotes = Datos.lotes()
    lineas = Datos.lineas()
    confeccionistas = Datos.confeccionistas()

    validar_todos(lotes, confeccionistas, lineas)
  end

  @doc """
  Recorre los lotes separándolos en válidos y rechazados conservando el orden original.
  """
  def validar_todos(lotes, confeccionistas, lineas) do
    {validos_rev, rechazados_rev} =
      Enum.reduce(lotes, {[], []}, fn lote, {validos, rechazados} ->
        case validar_lote(lote, confeccionistas, lineas) do
          {:ok, lote_valido} ->
            {[lote_valido | validos], rechazados}

          {:error, motivo} ->
            registro_rechazo = %{lote: lote, motivo: motivo}
            {validos, [registro_rechazo | rechazados]}
        end
      end)

    {Enum.reverse(validos_rev), Enum.reverse(rechazados_rev)}
  end

  @doc """
  Valida un lote individual encadenando las 5 reglas en el orden exacto del parcial.
  Regresa únicamente la primera regla que incumple.
  """
  def validar_lote(lote, confeccionistas, lineas) do
    with :ok <- confeccionista_existe?(lote, confeccionistas),
         :ok <- linea_existe?(lote, lineas),
         :ok <- dia_valido?(lote),
         :ok <- prendas_en_rango?(lote),
         :ok <- porcentaje_valido?(lote) do
      {:ok, lote}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp confeccionista_existe?(%{confeccionista: codigo}, confeccionistas) when is_binary(codigo) do
    if Enum.any?(confeccionistas, fn c -> c.codigo == codigo end) do
      :ok
    else
      {:error, :confeccionista_desconocido}
    end
  end
  defp confeccionista_existe?(_lote, _confeccionistas), do: {:error, :confeccionista_desconocido}

  defp linea_existe?(%{linea: id_linea}, lineas) when is_binary(id_linea) do
    if Enum.any?(lineas, fn l -> l.id == id_linea end) do
      :ok
    else
      {:error, :linea_desconocida}
    end
  end
  defp linea_existe?(_lote, _lineas), do: {:error, :linea_desconocida}

  defp dia_valido?(%{dia: dia}) when is_integer(dia) and dia in 1..6, do: :ok
  defp dia_valido?(_lote), do: {:error, :dia_invalido}

  defp prendas_en_rango?(%{prendas: prendas}) when is_integer(prendas) and prendas >= 1 and prendas <= 180, do: :ok
  defp prendas_en_rango?(_lote), do: {:error, :prendas_fuera_de_rango}

  defp porcentaje_valido?(%{defectos: defectos}) when is_number(defectos) and defectos >= 0.0 and defectos <= 100.0, do: :ok
  defp porcentaje_valido?(_lote), do: {:error, :porcentaje_invalido}
end
