# Interface desenvolvida para Digital Twin do Projeto FeeFeeDer da disciplina de PCS3645
# Nomes e NUSP:
# Pedro Henrique Rodrigues Viveiros - 11804035
# Pedro Vitor Bacic - 11806934
# Victor de Almeida Santana -11806718


import paho.mqtt.client as mqtt
import serial

# Variáveis Globais:

# Variáveis de Comunicação com a FPGA:

# Variáveis usadas pela própria interface:

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

# MQTT Cria cliente
client = mqtt.Client()
client.on_connect = on_connect      
client.on_message = on_message  
client.username_pw_set(user, passwd)


if __name__ == '__main__':
    client.connect(Broker, Port, KeepAlive)
    client.loop_start()

    with serial.Serial('COM9', 115200) as porta: 	
        while True:
            linha1  = porta.read(3)
            hashtag = porta.read(1)
            linha2  = porta.read(3)
            client.publish(user+"/TX", payload=linha1, qos=0, retain=False)
            client.publish(user+"/RX", payload=linha2, qos=0, retain=False)
            print(linha1)
            print(linha2)

    client.loop_stop()
    client.disconnect()