defmodule MedicionesC3 do
  def ejecutar do
    IO.puts("=== EXPERIMENTO 1: Búsqueda en Lista vs Mapa ===")
    lista_confeccionistas =
      Enum.map(1..100_000, fn i ->
        %{codigo: "C#{i}", nombre: "Confeccionista #{i}"}
      end)

    mapa_confeccionistas = Map.new(lista_confeccionistas, fn c -> {c.codigo, c} end)
    codigos_azar = Enum.map(1..1_000, fn _ -> "C#{Enum.random(1..100_000)}" end)
    {tiempo_lista, _} =
      :timer.tc(fn ->
        Enum.each(codigos_azar, fn cod ->
          Enum.find(lista_confeccionistas, fn c -> c.codigo == cod end)
        end)
      end)

    {tiempo_mapa, _} =
      :timer.tc(fn ->
        Enum.each(codigos_azar, fn cod ->
          Map.get(mapa_confeccionistas, cod)
        end)
      end)

    IO.puts("Tiempo en lista (Enum.find): #{tiempo_lista / 1_000} ms")
    IO.puts("Tiempo en mapa (Map.get):    #{tiempo_mapa / 1_000} ms")
    IO.puts("\n=== EXPERIMENTO 2: Construcción de Lista con Enum.reduce ===")
    {tiempo_concat, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn i, acc ->
          acc ++ [i]
        end)
      end)

    {tiempo_prep, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn i, acc ->
          [i | acc]
        end)
      end)

    IO.puts("Tiempo con '++':         #{tiempo_concat / 1_000} ms")
    IO.puts("Tiempo con '[elem|acc]': #{tiempo_prep / 1_000} ms")
  end
end
