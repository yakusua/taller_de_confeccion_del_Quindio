
defmodule VerificacionDatos do
  @moduledoc """
  este modulo es el encargado de verificar que los datos si cumplan con la estructura, dejando de lado las verificaciones por logica de negocio.
  a validacion_lotes.exs
  """

  @doc """
  esta funcion comprueba que el confeccionista cumpla con la estructura y el tipo de datos
  """
  def comprobar_confeccionista(%{codigo: codigo, nombre: nombre, alquiler: alquiler} = mapa)
  when is_binary(codigo) and is_binary(nombre) and is_boolean(alquiler) do

    if map_size(mapa) == 3 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end

  end

  @doc """
  esta funcion es la respuesta en caso de que el confeccionista tenga alguna otra forma, o este erroneo
  """
  def comprobar_confeccionista(_) do
    {:error, "en los datos.exs, la estructura de confeccionista tiene tipos de datos incorrectos"}
  end

  @doc """
  esta funcion comprueba que la linea cumpla con la estructura y el tipo de datos
  """
  def comprobar_linea(%{id: id, nombre: nombre, puestos: puestos} = mapa)
    when is_binary(id) and is_binary(nombre) and is_integer(puestos) do

    if map_size(mapa) == 3 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end
  end

  @doc """
  esta funcion es la respuesta en caso de que la linea tenga alguna otra forma, o este erronea
  """
  def comprobar_linea(_) do
    {:error, "en los datos.exs, las lineas tienen tipos de datos incorrectos"}
  end

  @doc """
  esta funcion comprueba que el lote cumpla con la estructura y el tipo de datos
  """
  def comprobar_lote(%{confeccionista: confeccionista, linea: linea, dia: dia, prendas: prendas, defectos: defectos} = mapa)
    when is_binary(confeccionista) and is_binary(linea) and is_integer(dia) and is_integer(prendas) and is_number(defectos) and confeccionista != "" and linea != "" do

    if map_size(mapa) == 5 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end
  end

  @doc """
  esta funcion es la respuesta en caso de que el lote tenga alguna otra forma, o este erronea
  """
  def comprobar_lote(_) do
    {:error, "en los datos.exs, los lotes tienen tipos de datos incorrectos"}
  end
end
