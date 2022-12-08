# Interface desenvolvida para Digital Twin do Projeto FeeFeeDer da disciplina de PCS3645
# Nomes e NUSP:
# Pedro Henrique Rodrigues Viveiros - 11804035
# Pedro Vitor Bacic - 11806934
# Victor de Almeida Santana -11806718

from turtle import Screen, distance
import kivy

from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.screenmanager import Screen, ScreenManager
from kivy.lang import Builder
from kivy.properties import StringProperty

import paho.mqtt.client as mqtt
from kivy.clock import Clock
import time

# Variáveis Globais:

# Variáveis de Comunicação com a FPGA:
global dist_rev1
dist_rev1 = 0
global dist_rev2
dist_rev2 = 0

# Variáveis usadas pela própria interface:
global porcentagemA
porcentagemA = 50
global porcentagemB
porcentagemB = 50

# Login no MQTT
user = "grupo1-bancadaA5" # TODO: Ajustar os parametros de login
passwd = "digi#@1A5"
Broker = "labdigi.wiseful.com.br"
Port = 80
KeepAlive = 60

# MQTT (Callback de conexao)
def on_connect(client, userdata, flags, rc):
    print("Conectado com codigo " + str(rc))
    client.subscribe(user+"/RX", qos=0)
    client.subscribe(user+"/TX", qos=0)

# MQTT (Callback de mensagem)
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload)) # Printa no terminal o topico alterado

    # Variaveis Globais
    global porcentagemA
    global porcentagemB

    if(user+"/TX" == msg.topic):
        porcentagemB = porcentage(int(msg.payload), 30)
        print(f'Reservatorio em {porcentagemB}%')
    elif(user+"/RX" == msg.topic):
        porcentagemA = porcentage(int(msg.payload), 17)
        print(f'Comedouro em {porcentagemA}%')

# MQTT Cria cliente
client = mqtt.Client()
client.on_connect = on_connect      
client.on_message = on_message  
client.username_pw_set(user, passwd)

def image_load(porcentage):
    if porcentage == 100:
        return "imagens/Reservatório.png"
    elif porcentage >= 90 and porcentage < 100:
        return "imagens/Reservatório - 90.png"
    elif porcentage >= 80 and porcentage < 90:
        return "imagens/Reservatório - 80.png"
    elif porcentage >= 75 and porcentage < 80:
        return "imagens/Reservatório - 75.png"
    elif porcentage >= 70 and porcentage < 75:
        return "imagens/Reservatório - 70.png"
    elif porcentage >= 60 and porcentage < 70:
        return "imagens/Reservatório - 60.png"
    elif porcentage >= 50 and porcentage < 60:
        return "imagens/Reservatório - 50.png"
    elif porcentage >= 40 and porcentage < 50:
        return "imagens/Reservatório - 40.png"
    elif porcentage >= 30 and porcentage < 40:
        return "imagens/Reservatório - 30.png"
    elif porcentage >= 20 and porcentage < 30:
        return "imagens/Reservatório - 20.png"
    elif porcentage >= 10 and porcentage < 20:
        return "imagens/Reservatório - 10.png"
    elif porcentage >= 0 and porcentage < 10:
        return "imagens/Reservatório - 0.png"
    else:
        return "imagens/Reservatório - 70.png"


def porcentage(dist, max):
    porcentagem = round((100 * dist) / max) - 100

    if porcentagem < 0:
        porcentagem = porcentagem * (-1)

    return porcentagem


class Main(Screen):
    i = 0
    porcentageA = porcentage(25, 100)
    porcentageB = porcentage(50, 100)
    contentA = StringProperty()
    contentB = StringProperty()
    imageA = image_load(porcentageA)
    imageB = image_load(porcentageB)

    def action(self):
        global porcentagemA
        global porcentagemB
        
        return str(porcentagemA), str(porcentagemB), image_load(porcentagemA), image_load(porcentagemB)

    def update(self, dt):
        self.contentA, self.contentB, self.ids.imageA.source, self.ids.imageB.source = self.action()

#kv = Builder.load_file("main.kv")


class MainApp(App):

    def build(self):
        Builder.load_file("main.kv")
        myMain = Main()
        Clock.schedule_interval(myMain.update, 1)
        return myMain


if __name__ == '__main__':
    client.connect(Broker, Port, KeepAlive)
    client.loop_start()

    MainApp().run()

    client.loop_stop()
    client.disconnect()
