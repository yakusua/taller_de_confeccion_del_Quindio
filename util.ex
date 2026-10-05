defmodule Util do
  @moduledoc """
  Módulo de utilidades puras para el Parcial 1.
  Cumple con todas las restricciones de la asignatura.
  """

  @doc """
  Muestra un mensaje en la consola.
  """
  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  @doc """
  Muestra un mensaje de error en la consola.
  """
  def mostrar_error(mensaje) do
    IO.puts(:stderr, mensaje)
  end


  @doc """
  Solicita al usuario ingresar un valor y lo devuelve como texto, entero, real o booleano según el tipo especificado.
  """
  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> to_string()
    |> String.trim()
  end

  @doc """
  Solicita al usuario ingresar un valor y lo devuelve como entero.
  """
  def ingresar(mensaje, :entero) do
    texto = ingresar(mensaje, :texto)

    case Integer.parse(texto) do
      {entero, ""} ->
        {:ok, entero}

      _ ->
        mostrar_error("Error: se esperaba un número entero.")
        {:error, :no_es_entero}
    end
  end

  @doc """
  Solicita al usuario ingresar un valor y lo devuelve como real (float).
  """
  def ingresar(mensaje, :real) do
    texto = ingresar(mensaje, :texto)

    case Float.parse(texto) do
      {flotante, ""} ->
        {:ok, flotante}

      _ ->
        case Integer.parse(texto) do
          {entero, ""} -> {:ok, entero * 1.0}
          _ ->
            mostrar_error("Error: se esperaba un número real.")
            {:error, :no_es_real}
        end
    end
  end

  @doc """
  Solicita al usuario ingresar un valor y lo devuelve como booleano.
  """
  def ingresar(mensaje, :booleano) do
    texto =
      mensaje
      |> ingresar(:texto)
      |> String.downcase()

    texto in ["si", "s", "true", "1"]
  end


  @doc """
  Formatea un valor para su impresión en la consola.
  """
  def formater(valor) when is_float(valor) do
    :erlang.float_to_binary(valor, decimals: 2)
  end

  @doc """
  Formatea un valor entero para su impresión en la consola.
  """
  def formater(valor) when is_integer(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end
end
