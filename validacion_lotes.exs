defmodule ValidacionLotes do
  @moduledoc """
  este modulo contiene la logica de negocio, encargada de validar los lotes.
  """

#   Regla                                                   Motivo de rechazo
#   El confeccionista existe                                :confeccionista_desconocido
#   La línea de producción existe                           :linea_desconocida
#   El día es un entero entre 1 y 6                         :dia_invalido
#   La cantidad de prendas es un entero entre 1 y 180       :prendas_fuera_de_rango
#   El porcentaje de defectos es un número entre 0 y 100    :porcentaje_invalido


  @doc """
  esta funcion, accede a los datos de datos.exs, realiza la validacion de cada lote, en su each.
  si esta bien, devuelve {:ok, lote}, si no, devuelve {:error, motivo}.
  """
  def validar_lotes do

    lotes = Datos.lotes()
    |> validacion_basica_de_datos()

    lineas = Datos.lineas()
    |> validacion_basica_de_datos()

    confeccionistas = Datos.confeccionistas()
    |> validacion_basica_de_datos()

    {lotes_validos, lotes_rechazados} = validar_todos(lotes, confeccionistas, lineas)

  end

  @doc "Valida todos los lotes y los separa en válidos y rechazados."
  def validar_todos(lotes, confeccionistas, lineas) do
    Enum.reduce(lotes, {[], []}, fn lote, {validos, rechazados} ->
      case validar_lote(lote, confeccionistas, lineas) do
      {:ok, lote_valido} ->
        {[lote_valido | validos], rechazados}

      {:error, motivo} ->
        registro_rechazo = %{lote: lote, motivo: motivo}
        {validos, [registro_rechazo | rechazados]}
      end

    end)

  end

  @doc """
  esta funcion valida una lista de confeccionistas, lineas o lotes, verificando que cumplan con la estructura basica.
  si esta bien, devuelve {:ok, lista}, si no, devuelve {:error, lista}
  """
  defp validar_confeccionistas(lista) do
    validar_coleccion(lista, &VerificacionDatos.comprobar_confeccionista/1)
  end

  defp validar_lineas(lista) do
    validar_coleccion(lista, &VerificacionDatos.comprobar_linea/1)
  end

  defp validar_lista_lotes(lista) do
    validar_coleccion(lista, &VerificacionDatos.comprobar_lote/1)
  end

  defp validar_coleccion(lista, funcion_validadora) do
    resultado = Enum.map(lista, funcion_validadora)
  end

  @doc """
  esta funcion utiliza la funcion validar_coleccion para validar una lista de confeccionistas, lineas o lotes.
  mediante Enum.map, recorre por la lista y revisa cada elemento, para devolver, {:ok, lista} si esta bien y si no,
  devuelve {:error, lista}.
  """
  def validacion_basica_de_datos (confeccionistas) do
    Enum.map(confeccionistas, fn confeccionista ->
      confeccionista
      |> VerificacionDatos.comprobar_confeccionista()
    end)
  end

  @doc """
  esta funcion valida un lote, verificando que cumpla con las reglas de negocio.
  si esta bien, devuelve {:ok, lote}, si no, devuelve {:error, motivo}.
  """
  defp validar_lote({:ok, lote}, {:ok, lineas}, {:ok, confeccionistas}) do

    with {:ok, _} <- VerificacionDatos.comprobar_lote(lote),  #estos evaluan si cumplen con las logica de negocio
         :ok <- confeccionista_existe?(lote.confeccionista, confeccionistas),
         :ok <- linea_existe?(lote.linea, lineas),
         :ok <- dia_valido?(lote.dia),
         :ok <- prendas_en_rango?(lote.prendas),
         :ok <- porcentaje_valido?(lote.defectos) do

      {:ok, lote}
    else
      {:error, motivo}

    end
  end

  defp validar_lote(_lote, _lineas, _confeccionistas) do
    {:error, :estructura_invalida}
  end

  @doc """
  esta funcion valida que el confeccionista exista en los datos de datos.exs.
  """
  defp confeccionista_existe?(codigo, confeccionistas) do
    if Enum.any?(confeccionistas, fn c -> c.codigo == codigo end) do
      :ok
    else
      {:error, :confeccionista_desconocido}
    end
  end

  @doc """
  esta funcion valida que la linea exista en los datos de datos.exs.
  """
  defp linea_existe?(id, lineas) do
    if Enum.any?(lineas, fn linea -> linea.id == id end) do
      :ok
    else
      {:error, :linea_desconocida}
    end
  end

  @doc """
  esta funcion valida que el dia sea un entero entre 1 y 6.
  """
  defp dia_valido?(dia) when dia in 1..6, do: :ok
  defp dia_valido?(_), do: {:error, :dia_invalido}

  @doc """
  esta funcion valida que la cantidad de prendas sea un entero entre 1 y 180.
  """
  defp prendas_en_rango?(prendas) when prendas >= 1 and prendas <= 180, do: :ok
  defp prendas_en_rango?(_), do: {:error, :prendas_fuera_de_rango}

  @doc """
  esta funcion valida que el porcentaje de defectos sea un número entre 0 y 100.
  """
  defp porcentaje_valido?(defectos) when defectos >= 0 and defectos <= 100, do: :ok
  defp porcentaje_valido?(_), do: {:error, :porcentaje_invalido}

end
