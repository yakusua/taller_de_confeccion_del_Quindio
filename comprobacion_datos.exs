
defmodule VerificacionDatos do

  def comprobar_confeccionista(%{codigo: codigo, nombre: nombre, alquiler: alquiler} = mapa)
  when is_binary(codigo) and is_binary(nombre) and is_boolean(alquiler) do

    if map_size(mapa) == 3 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end

  end

  def comprobar_confeccionista(_) do
    {:error, "en los datos.exs, la estructura de confeccionista tiene tipos de datos incorrectos"}
  end

  def comprobar_linea(%{id: id, nombre: nombre, puestos: puestos} = mapa)
    when is_binary(id) and is_binary(nombre) and is_integer(puestos) do

    if map_size(mapa) == 3 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end
  end

  def comprobar_linea(_) do
    {:error, "en los datos.exs, las lineas tienen tipos de datos incorrectos"}
  end

  def comprobar_lote(%{confeccionista: confeccionista, linea: linea, dia: dia, prendas: prendas, defectos: defectos} = mapa)
    when is_binary(confeccionista) and is_binary(linea) and is_integer(dia) and is_integer(prendas) and is_number(defectos) do

    if map_size(mapa) == 5 do
      {:ok, mapa}
    else
      {:error, "en los datos.exs, el mapa contiene campos adicionales no permitidos"}
    end
  end

  def comprobar_lote(_) do
    {:error, "en los datos.exs, los lotes tienen tipos de datos incorrectos"}
  end

end
