defmodule Util do
  @moduledoc """
  Módulo de utilidades puras para el Parcial 1.
  Cumple con todas las restricciones de la asignatura.
  """

  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  def mostrar_error(mensaje) do
    IO.puts(:stderr, mensaje)
  end


  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> to_string()
    |> String.trim()
  end

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

  def ingresar(mensaje, :booleano) do
    texto =
      mensaje
      |> ingresar(:texto)
      |> String.downcase()

    texto in ["si", "s", "true", "1"]
  end


  def formater(valor) when is_float(valor) do
    :erlang.float_to_binary(valor, decimals: 2)
  end

  def formater(valor) when is_integer(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end
end
