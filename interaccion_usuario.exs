defmodule InteraccionUsuario do
  @moduledoc """
  Módulo que maneja la interacción con el usuario para el taller de confección.
  """

  @doc """
  Pide un lote adicional por consola, lo valida sintácticamente y retorna:
  - :omitido si el usuario presiona Enter.
  - {:ok, lote_mapa} si el formato es correcto.
  - {:error, :formato_invalido} si falla la conversión de tipos o cantidad de campos.
  """
  def pedir_lote_adicional do
    IO.puts("Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos)")
    entrada = IO.gets("o Enter para omitir: ") |> String.trim()

    if entrada == "" do
      :omitido
    else
      procesar_entrada_lote(entrada)
    end
  end

  defp procesar_entrada_lote(entrada) do
    campos = String.split(entrada, ";")

    if length(campos) == 5 do
      [c, l, dia_str, prendas_str, defectos_str] = Enum.map(campos, &String.trim/1)

      case {Integer.parse(dia_str), Integer.parse(prendas_str), Float.parse(defectos_str)} do
        {{dia, ""}, {prendas, ""}, {defectos, ""}} ->
          {:ok, %{confeccionista: c, linea: l, dia: dia, prendas: prendas, defectos: defectos}}

        {{dia, ""}, {prendas, ""}, {defectos, _resto}} when is_float(defectos) or is_integer(defectos) ->
          {:ok, %{confeccionista: c, linea: l, dia: dia, prendas: prendas, defectos: defectos}}

        _ ->
          {:error, :formato_invalido}
      end
    else
      {:error, :formato_invalido}
    end
  end

  @doc """
  Solicita el código de un confeccionista y muestra su comprobante detallado.
  """
  def consultar_comprobante(lotes_validos, confeccionistas) do
    codigo_ingresado =
      IO.gets("\nIngrese el código del confeccionista para ver comprobante: ")
      |> String.trim()

    confeccionista = Enum.find(confeccionistas, fn c -> c.codigo == codigo_ingresado end)

    if confeccionista == nil do
      IO.puts("El confeccionista con código '#{codigo_ingresado}' no existe.")
    else
      mostrar_comprobante(confeccionista, lotes_validos)
    end
  end

 defp mostrar_comprobante(confeccionista, lotes_validos) do
    lotes_c = Enum.filter(lotes_validos, fn l -> l.confeccionista == confeccionista.codigo end)

    dias_trabajados =
      1..6
      |> Enum.map(fn dia ->
        lotes_dia = Enum.filter(lotes_c, fn l -> l.dia == dia end)

        if lotes_dia == [] do
          nil
        else
          total_prendas_dia = Enum.sum(Enum.map(lotes_dia, fn l -> l.prendas end))

          # CORRECCIÓN: Se cambia Calculos por Liquidacion
          valor_lotes_dia = Enum.sum(Enum.map(lotes_dia, fn l -> Liquidacion.calcular_valor_lote(l) end))
          bonificacion_dia = Liquidacion.calcular_bonificacion_productividad(lotes_dia)

          %{
            dia: dia,
            prendas: total_prendas_dia,
            valor_lotes: valor_lotes_dia,
            bonificacion: bonificacion_dia
          }
        end
      end)
      |> Enum.reject(fn d -> d == nil end)

    suma_lotes = Enum.sum(Enum.map(dias_trabajados, fn d -> d.valor_lotes end))
    suma_bonificaciones = Enum.sum(Enum.map(dias_trabajados, fn d -> d.bonificacion end))

    cant_dias = length(dias_trabajados)
    descuento_alquiler = Liquidacion.calcular_alquiler(confeccionista, cant_dias)

    neto = suma_lotes + suma_bonificaciones - descuento_alquiler

    IO.puts("\n==================================================")
    IO.puts(" COMPROBANTE INDIVIDUAL DE PAGO")
    IO.puts("==================================================")
    IO.puts("Nombre: #{confeccionista.nombre}")
    IO.puts("Código: #{confeccionista.codigo}")
    IO.puts("--------------------------------------------------")
    IO.puts("DÍAS TRABAJADOS:")

    Enum.each(dias_trabajados, fn d ->
      IO.puts(" Día #{d.dia}: #{d.prendas} prendas | Valor lotes: $#{d.valor_lotes} | Bonif: $#{d.bonificacion}")
    end)

    IO.puts("--------------------------------------------------")
    IO.puts("Suma de Lotes:         $#{suma_lotes}")
    IO.puts("Suma de Bonificaciones:$#{suma_bonificaciones}")
    IO.puts("Descuento Alquiler:   -$#{descuento_alquiler}")
    IO.puts("--------------------------------------------------")
    IO.puts("NETO A PAGAR:          $#{neto}")
    IO.puts("==================================================\n")
  end
end
