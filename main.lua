-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- inclui a biblioteca "widget" do Corona
local widget = require "widget"

-- configura a barra de status
display.setStatusBar( display.DarkTransparentStatusBar )

-- configura o plano de fundo para cinza
display.setDefault( "background", 0.8 )

-- configura as ancoras padrões dos elementos de interface
display.setDefault( "anchorX" , 0 )
display.setDefault( "anchorY" , 0 )

-- variáveis para armazenar os operandos e o operador
local operator = nil
local operand1 = nil
local operand2 = nil

-- variável auxiliar para testar a próxima entrada do usuário
local nextOperand = false

-- tamanho da barra de status
local statusBarHeight = display.topStatusBarContentHeight

-- tamanho do conteúdo da tela
local contentHeight = display.actualContentHeight - statusBarHeight
local contentWidth = display.actualContentWidth

-- tamanho de cada elemento da interface
local elementWidth = contentWidth / 4 - 0.5
local elementHeight = contentHeight / 7 - 0.25
local elementWide = elementWidth * 2 -- botão com o dobro do tamanho

-- tabelas para criação da grade de enquadramento da interface
gridX = { 0, elementWidth, elementWidth * 2, elementWidth * 3 }
gridY = {
  statusBarHeight,
  statusBarHeight + elementHeight,
  statusBarHeight + elementHeight * 2,
  statusBarHeight + elementHeight * 3,
  statusBarHeight + elementHeight * 4,
  statusBarHeight + elementHeight * 5,
  statusBarHeight + elementHeight * 6
}

-- tabela com as opções gerais para criação dos elementos de texto
local textOptions = { text = "", x = display.contentCenterX, width = contentWidth - 24, height = elementHeight, align = "right" }

-- cria texto primário da calculadora
local primaryText = display.newText( textOptions )

-- padrões do elemento de texto primário
primaryText.text = "0"
primaryText.y = gridY[2]
primaryText.anchorX = 0.5
primaryText.size = 46
primaryText:setFillColor(0)

-- cria texto secundário da calculadora
local secondaryText = display.newText( textOptions )

-- padrões do elemento de texto secundário
secondaryText.anchorX = 0.5
secondaryText.y = gridY[1] + elementHeight / 2
secondaryText:setFillColor(0.2)

-- evento de interação com os botões de número
function handleNumbersButtonEvent( event )
  if ( "ended" == event.phase ) then
    -- se o texto for igual a zero, ou se o programa estiver esperando uma
    -- entrada do usuário o texto deve ser apagado
    if ( primaryText.text == "0" or nextOperand) then
      primaryText.text = ""
    end

    -- atualiza o texto adicionando o texto do botão que foi interagido
    primaryText.text = primaryText.text .. event.target:getLabel()

    -- retira a espera de entrada do usuário
    nextOperand = false
  end
end

-- evento de interação com os botões de limpeza do texto do display
function handleClearButtonsEvent( event )
  if ( "ended" == event.phase) then
-- limpa todo texto do display bem como zera os valores das variáveis de operandos
    if ( event.target:getLabel() == "C" ) then
      operand1 = nil
      operand2 = nil
      secondaryText.text = ""
      primaryText.text = "0"
    -- apenas limpa o texto primário, mantendo os valores das variáveis de operandos
    elseif ( event.target:getLabel() == "CE" ) then
      primaryText.text = "0"
    -- ação do botão de backspace
    elseif ( event.target:getLabel() == "⌫" ) then
      -- apaga o ultimo caractere do texto primário
      primaryText.text = primaryText.text:sub(1, -2)
      -- caso não haja mais caracteres configura o texto pra 0
      if ( primaryText.text == "" ) then
        primaryText.text = "0"
      end
    end
  end
end

-- evento de interação com os botões de operadores
function handleOperatorsButtonEvent( event )
  if ( "ended" == event.phase ) then
    -- testa se o programa não está esperando por uma entrada do usuário
    if (not nextOperand) then
      -- configura o texto sencundário com a entrada do primário
      secondaryText.text = secondaryText.text .. primaryText.text

      -- verifca qual operando deverá receber o valor
      -- se os operandos tiverem valor diferente de nulo, efetua a função de resultado
      if ( operand1 ~= nil and primaryText.text ~= "0") then
        operand2 = primaryText.text -- define o segundo operando
        handleEqualButtonEvent() -- efetua a equação
        operand1 = primaryText.text -- define o resultado como primeiro operando
      else
        operand1 = primaryText.text -- define o texto primário como primeiro operando
      end

      -- configura a espera do programa à uma entrada do usuário
      nextOperand = true

      -- testa se já existem valor para o operador
      if ( operator == nil) then
        -- testa qual operador foi interagido
        if ( event.target:getLabel() == "+") then
          operator = 1
        elseif ( event.target:getLabel() == "-") then
          operator = 2
        elseif ( event.target:getLabel() == "×") then
          operator = 3
        elseif ( event.target:getLabel() == "÷") then
          operator = 4
        end

        -- atualiza as informações do texto secundário adicionando o operador
        secondaryText.text = secondaryText.text .. " " .. event.target:getLabel() .. " "
      end
    end
  end
end

-- evento de interação com o botão de resultado (igual)
function handleEqualButtonEvent( event )
  -- o processo de resultado da equação depende do valor do primeiro operando existir
  if ( operand1 ~= nil) then
    -- define o segundo operando
    operand2 = primaryText.text

    -- configura a espera do programa à uma entrada do usuário
    nextOperand = true

    -- testa os operadores e define a operação para cada um
    if ( operator == 1) then
      primaryText.text = operand1 + operand2
    elseif ( operator == 2) then
      primaryText.text = operand1 - operand2
    elseif ( operator == 3) then
      primaryText.text = operand1 * operand2
    elseif ( operator == 4) then
      primaryText.text = operand1 / operand2
    end

    -- zera todos as variáveis relacionadas a equação
    operand1 = nil
    operand2 = nil
    operator = nil
  end

  -- apaga o texto secundário somente se houver interação com o botão de igual
  if (event ~= nil and event.target:getLabel() == "=") then
    secondaryText.text = ""
  end
end

-- evento de interação para o botão de ponto
function handleDotButtonEvent( event )
  if ( "ended" == event.phase) then
    -- testa se já existe algum ponto no texto primário
    if ( string.find( primaryText.text, "%." ) == nil ) then
      primaryText.text = primaryText.text .. "."
    end
  end
end

-- tabela para configuração dos botões
local tabButtons = {
  { label = "CE", height = elementHeight, width = elementWidth, x = gridX[1], y = gridY[3], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 15, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleClearButtonsEvent    },
  { label = "C",  height = elementHeight, width = elementWidth, x = gridX[2], y = gridY[3], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 15, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleClearButtonsEvent    },
  { label = "⌫", height = elementHeight, width = elementWidth, x = gridX[3], y = gridY[3], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 15, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleClearButtonsEvent    },
  { label = "÷",  height = elementHeight, width = elementWidth, x = gridX[4], y = gridY[3], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 24, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleOperatorsButtonEvent },
  { label = "7",  height = elementHeight, width = elementWidth, x = gridX[1], y = gridY[4], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "8",  height = elementHeight, width = elementWidth, x = gridX[2], y = gridY[4], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "9",  height = elementHeight, width = elementWidth, x = gridX[3], y = gridY[4], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "×",  height = elementHeight, width = elementWidth, x = gridX[4], y = gridY[4], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 24, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleOperatorsButtonEvent },
  { label = "4",  height = elementHeight, width = elementWidth, x = gridX[1], y = gridY[5], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "5",  height = elementHeight, width = elementWidth, x = gridX[2], y = gridY[5], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "6",  height = elementHeight, width = elementWidth, x = gridX[3], y = gridY[5], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "-",  height = elementHeight, width = elementWidth, x = gridX[4], y = gridY[5], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 34, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleOperatorsButtonEvent },
  { label = "1",  height = elementHeight, width = elementWidth, x = gridX[1], y = gridY[6], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "2",  height = elementHeight, width = elementWidth, x = gridX[2], y = gridY[6], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "3",  height = elementHeight, width = elementWidth, x = gridX[3], y = gridY[6], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = "+",  height = elementHeight, width = elementWidth, x = gridX[4], y = gridY[6], labelColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255 } }, fontSize = 24, shape = "rect", fillColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.85, 0.85, 0.85 } },                         strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleOperatorsButtonEvent },
  { label = "0",  height = elementHeight, width = elementWide,  x = gridX[1], y = gridY[7], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleNumbersButtonEvent   },
  { label = ".",  height = elementHeight, width = elementWidth, x = gridX[3], y = gridY[7], labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },                                   fontSize = 34, shape = "rect", fillColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },                                  strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onEvent = handleDotButtonEvent       },
  { label = "=",  height = elementHeight, width = elementWidth, x = gridX[4], y = gridY[7], labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } },                                   fontSize = 24, shape = "rect", fillColor = { default={ 41/255, 143/255, 204/255 }, over={ 41/255, 143/255, 204/255, 0.8 } }, strokeWidth = 1, strokeColor = { default={ 0.8 }, over={ 0.8 } }, onRelease = handleEqualButtonEvent   }
}

-- cria todos os botões percorrendo todos os dados da tabela de botões
for i = 1, #tabButtons do
  widget.newButton( tabButtons[i] )
end
