local coroutine = require("coroutine")
local math = require("math")

local function escolher_ataque()
  local numero_aleatorio = math.random(1, 20)
  if numero_aleatorio <= 10 then
    return "Choque do Trovão", 50
  elseif numero_aleatorio <= 15 then
    return "Cauda de Ferro", 100
  elseif numero_aleatorio <= 18 then
    return "Investida Trovão", 150
  else
    return "Trovão", 200
  end
end

local function pokemon_battle(pokemon1, hp1, pokemon2, hp2)
  local turno = 1
  while hp1 > 0 and hp2 > 0 do
    coroutine.yield(turno, pokemon1, hp1, pokemon2, hp2)

    local ataque, dano
    if turno % 2 == 1 then
      ataque, dano = escolher_ataque()
      print(pokemon1 .. " usou " .. ataque .. "!")
      hp2 = hp2 - dano
    else
      ataque, dano = escolher_ataque()
      print(pokemon2 .. " usou " .. ataque .. "!")
      hp1 = hp1 - dano
    end

    turno = turno + 1
  end

  return turno, pokemon1, hp1, pokemon2, hp2
end

local function main()
  local pikachu_hp = 800
  local raichu_hp = 1000

  local battle = coroutine.create(function()
    return pokemon_battle("Pikachu", pikachu_hp, "Raichu", raichu_hp)
  end)

  while coroutine.status(battle) ~= "dead" do
    local ok, turno, pikachu, pikachu_hp_atual, raichu, raichu_hp_atual = coroutine.resume(battle)
    print("Turno " .. turno .. ": Pikachu HP = " .. pikachu_hp_atual .. ", Raichu HP = " .. raichu_hp_atual)
  end

  if pikachu_hp <= 0 and raichu_hp <= 0 then
    print("A batalha terminou em empate!")
  elseif pikachu_hp <= 0 then
    print("Raichu venceu a batalha!")
  else
    print("Pikachu venceu a batalha!")
  end
end

main()