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

# Variáveis Globais:

# Variáveis de Comunicação com a FPGA:
global dist_rev1
dist_rev1 = 0
global dist_rev2
dist_rev2 = 0

# Variáveis usadas pela própria interface:
global porcentage1
porcentage1 = 0
global porcentage2
porcentage2 = 0

# Login no MQTT


class Main(Screen):
    pass


def porcentage(dist):
    return 100 - dist


kv = Builder.load_file("main.kv")


class MainApp(App):

    def build(self):
        return kv


if __name__ == '__main__':
    MainApp().run()
