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

# Variáveis Globais:

# Variáveis de Comunicação com a FPGA:
global dist_rev1
dist_rev1 = 0
global dist_rev2
dist_rev2 = 0

# Variáveis usadas pela própria interface:

# Login no MQTT


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


def porcentage(dist):
    return 100 - dist


class Main(Screen):
    porcentageA = porcentage(25)
    porcentageB = porcentage(50)
    contentA = str(porcentageA)
    contentB = str(porcentageB)
    imageA = image_load(porcentageA)
    imageB = image_load(porcentageB)
    pass


kv = Builder.load_file("main.kv")


class MainApp(App):

    def build(self):
        return kv


if __name__ == '__main__':
    MainApp().run()
