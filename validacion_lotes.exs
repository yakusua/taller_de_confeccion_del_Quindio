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
    with :ok <- validar_confeccionista(lote, confeccionistas),
         :ok <- validar_linea(lote, lineas),
         :ok <- dia_valido?(lote),
         :ok <- prendas_en_rango?(lote),
         :ok <- porcentaje_valido?(lote) do
      {:ok, lote}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  @doc """
  valida que el confeccionista cumple con las directrices de comprobacion_datos.exs y si no , devuelve como motivo de error :error_de_datos,
  si el confeccionista no existe, devuelve como motivo de error :confeccionista_desconocido
  """
  defp validar_confeccionista(%{confeccionista: codigo}, confeccionistas) do
    case Enum.find(confeccionistas, fn c -> c.codigo == codigo end) do
      nil ->
        {:error, :confeccionista_desconocido}

      confeccionista ->
        case VerificacionDatos.comprobar_confeccionista(confeccionista) do
          {:ok, _} -> :ok
          {:error, _motivo} -> {:error, :error_de_datos}
          _-> {:error, :error_de_datos}
        end
    end
  end

  @doc """
  si no cumple con la esa de linea, devuelve como motivo de error :confeccionista_desconocido.
  """
  defp validar_confeccionista(_lote, _confeccionistas), do: {:error, :confeccionista_desconocido}

  @doc """
  valida que la linea cumpla con las directrices de comprobacion_datos.exs y si no , devuelve como motivo de error :error_de_datos,
  si la linea no existe, devuelve como motivo de error :linea_desconocida
  """
  defp validar_linea(%{linea: id_linea}, lineas)do
    case Enum.find(lineas, fn l -> l.id == id_linea end) do
      nil ->
        {:error, :linea_desconocida}

      linea ->
        case VerificacionDatos.comprobar_linea(linea) do
          {:ok, _} -> :ok
          {:error, _motivo} -> {:error, :error_de_datos}
        end
    end
  end

  @doc """
  si los dias son invalidos, devuelve como motivo de error :dia_invalido
  """
  defp dia_valido?(%{dia: dia}) when is_integer(dia) do
    if  dia in ParametrosTaller.dias_produccion() do
      :ok
    else
      {:error, :dia_invalido}
    end
  end
  @doc """
  si los dias son invalidos, devuelve como motivo de error :dia_invalido
  """
  defp dia_valido?(_lote), do: {:error, :dia_invalido}

  @doc """
  si las prendas estan fuera de rango, devuelve como motivo de error :prendas_fuera_de_rango
  """
  defp prendas_en_rango?(%{prendas: prendas}) when is_integer(prendas) do
    if prendas >= 1 and prendas <= ParametrosTaller.max_prendas_lote() do
      :ok
    else
      {:error, :prendas_fuera_de_rango}
    end
  end
  defp prendas_en_rango?(_lote), do: {:error, :prendas_fuera_de_rango}

  @doc """
  si el porcentaje de defectos es invalido, devuelve como motivo de error :porcentaje_invalido
  """
  defp porcentaje_valido?(%{defectos: defectos}) when is_number(defectos) and defectos >= 0.0 and defectos <= 100.0, do: :ok
  defp porcentaje_valido?(_lote), do: {:error, :porcentaje_invalido}

end
