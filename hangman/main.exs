defmodule Hangman do
  @moduledoc """
  Juego del Ahorcado

  Para jugar, ejecuta el siguiente comando en la terminal:
  $ elixir main.exs

  Para jugar con una palabra distinta, ejecuta el siguiente comando:
  $ elixir main.exs <palabra>

  """
  defstruct palabra: "", letras_adivinadas: %{}, intentos_maximos: 6, errores: 0

  @doc """
  Muestra la palabra actual con las letras adivinadas.
  """
  defp mostrar_palabra_actual(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas}) do
    palabra
    |> String.graphemes()
    |> Enum.map(&(letra_mostrada(&1, letras_adivinadas)))
    |> Enum.join(" ")
  end

  defp letra_mostrada(letra, letras_adivinadas) do
    if letra in letras_adivinadas, do: letra, else: "_"
  end

  defp mostrar_intentos(%Hangman{errores: errores, intentos_maximos: intentos_maximos, letras_adivinadas: letras_adivinadas}) do
    intentos_restantes = [intentos_maximos - errores, 0] |> Enum.max()
    "Intentos restantes: #{intentos_restantes}\nLetras adivinadas: #{Map.keys(letras_adivinadas) |> Enum.join(", ")}"
  end

  defp adivinar_letra() do
    IO.puts "Adivina una letra:"
    case validar_letra(IO.gets("") |> String.trim("\n") |> String.downcase()) do
      {:ok, letra} -> {:ok, letra}
      {:error, mensaje} ->
        IO.puts mensaje
        adivinar_letra()
    end
  end

  defp validar_letra(letra) do
    char_letra = hd(String.to_charlist(letra))
    if byte_size(letra) == 1 and char_letra in ?a..?z do
      {:ok, letra}
    else
      {:error, "Entrada inválida. Ingresa una letra válida."}
    end
  end

  defp palabra_adivinada?(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas}) do
    letras_distintas = String.graphemes(palabra) |> Enum.uniq()
    Enum.all?(letras_distintas, &(Map.get(letras_adivinadas, &1, false)))
  end

  defp contar_letras(palabra, letra) do
    palabra
    |> String.graphemes()
    |> Enum.filter(&(&1 == letra))
    |> length()
  end

  defp actualizar_juego(%Hangman{} = juego, letra) do
    if letra in String.graphemes(juego.palabra) do
      letras_adivinadas_actualizadas = Map.put(juego.letras_adivinadas, letra, true)
      nuevo_juego = %{juego | letras_adivinadas: letras_adivinadas_actualizadas}

      {:ok, nuevo_juego}
    else
      {:error, "¡Incorrecto! La letra #{letra} no está en la palabra."}
    end
  end

  defp juego_terminado?(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas}) do
    letras_distintas = String.graphemes(palabra) |> Enum.uniq()
    Enum.all?(letras_distintas, &(Map.get(letras_adivinadas, &1, false)))
  end

  defp mostrar_resultado(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas, errores: errores, intentos_maximos: intentos_maximos}) do
    palabra_mostrada = mostrar_palabra_actual(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas})
    IO.puts "Palabra: #{palabra_mostrada}"

    if juego_terminado?(%Hangman{palabra: palabra, letras_adivinadas: letras_adivinadas}) do
      IO.puts "¡Felicidades! Has adivinado la palabra: #{palabra}"
    else
      IO.puts "¡Oh no! Te has quedado sin intentos. La palabra era: #{palabra}"
    end
  end

  defp juego_perdido(%Hangman{palabra: palabra}) do
    IO.puts "¡Oh no! Te has quedado sin intentos. La palabra era: #{palabra}"
    System.halt(1)
  end

  defp finalizar_juego() do
    IO.puts "¡Juego terminado!"
    System.halt(0)
  end

  @doc """
  Inicia el juego del ahorcado.
  """
  def jugar(palabra) do
    juego = %Hangman{palabra: palabra}

    IO.puts "¡Bienvenido al Juego del Ahorcado!"

    loop(juego)
  end

  @doc """
  Loop principal del juego.
  """
  defp loop(%Hangman{} = juego) do
    mostrar_palabra_actual(juego) |> IO.puts()
    IO.puts mostrar_intentos(juego)

    if juego_terminado?(juego) do
      mostrar_resultado(juego)
      finalizar_juego()
    else
      case juego.errores >= juego.intentos_maximos do
        true ->
          juego_perdido(juego)
        false ->
          case adivinar_letra() do
            {:ok, letra} ->
              case actualizar_juego(juego, letra) do
                {:ok, nuevo_juego} ->
                  IO.puts "¡Correcto! La letra #{letra} está en la palabra."
                  loop(nuevo_juego)
                {:error, mensaje} ->
                  IO.puts mensaje
                  loop(%{juego | errores: juego.errores + 1, letras_adivinadas: juego.letras_adivinadas})
              end
            {:error, mensaje} ->
              IO.puts mensaje
              loop(%{juego | errores: juego.errores + 1, letras_adivinadas: juego.letras_adivinadas})
          end
      end
    end
  end
end


Hangman.jugar("elixir")
