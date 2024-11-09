# WattSync - Wattímetro Inteligente

O WattSync é um projeto de desenvolvimento de um wattímetro multifuncional que visa atender à crescente demanda por tecnologias de medição e gerenciamento de consumo elétrico em residências. Este dispositivo foi projetado para promover segurança, praticidade e eficiência, oferecendo uma série de funcionalidades que auxiliam no controle do uso de energia.

## 📋 Objetivo do Projeto
Desenvolver um dispositivo capaz de monitorar o consumo de energia elétrica em residências brasileiras, proporcionando acessibilidade e promovendo o controle de gastos com foco em sustentabilidade. O WattSync é voltado para auxiliar os usuários no entendimento e gerenciamento de seu consumo energético, além de fornecer recursos para desligamento remoto e proteção contra sobrecargas.

### Funcionalidades
- Medição de corrente, tensão, potência e frequência com precisão.
- Monitoramento remoto via aplicativo com conexão Wi-Fi.
- Desligamento automático em caso de sobrecarga.
- Desligamento automático em caso de subtensão ou sobretensão.
- Aviso sonoro em caso de desligamento.
- Limite de consumo configurável.
- Display para a visualização dos dados no própio dispositivo.
- Programação de horários para ligar e desligar os dispositivos.
- Interface amigável para visualizar e interpretar dados de consumo.

## 🛠️ Tecnologias Utilizadas

### Hardware
- **Microcontrolador:** ESP32S3 (wroom 1) e ATmega328P
- **Sensores de Corrente e Tensão**
- **Componentes de Proteção:** Varistor 14D561K, Fusível de Queima Rápida de 25A e Diodo Zener 1N4733A

### Software
- **Frontend do Aplicativo:** Flutter
- **Backend:** C (para o ESP32)
- **Armazenamento de Dados:** SQLite para o aplicativo
- **Ferramentas de Design:** Canva, Figma, Paint, Fritzing, KiCad, Astah UML
- **IDE:** Visual Studio Code, Arduino IDE, Google IDX
- **Versionamento de Código:** Git, Github

## 🚀 Como Executar o Projeto

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) para o aplicativo.
- [Arduino IDE](https://www.arduino.cc/en/software) para o ESP32 e ATmega328P.

  
### Passos para Configuração
1. Clone este repositório:
    ```bash
    git clone https://github.com/usuario/WattSync.git
    cd WattSync
    ```

2. Configure o ambiente de desenvolvimento Flutter:
    ```bash
    flutter pub get
    ```

3. Conecte o ESP32 ao computador e faça upload do código na pasta `esp32_code` para o dispositivo usando a Arduino IDE ou.

4. Execute o aplicativo:
    ```bash
    flutter run
    ```

5. No aplicativo, insira o código do produto para acessar as funcionalidades de monitoramento e controle.

## 📊 Resultados Esperados
- O WattSync oferece medição de corrente, tensão, potência e frequência, possibilitando o acompanhamento individualizado do consumo de cada aparelho conectado.
- Possui a capacidade de alertar o usuário e desligar automaticamente dispositivos em caso de sobrecarga.
- Interface intuitiva que facilita a interpretação dos dados de consumo e gera relatórios detalhados com gráficos de histórico.

## 💡 Estrutura do Projeto

- `app/`: Código do aplicativo Flutter, incluindo widgets e gráficos.
- `wattmeter/ESP32S3/`: Código para o ESP32, responsável por capturar os dados do ATmega328P e enviar ao aplicativo.
- `wattmeter/ATMEGA328P/`: Código para o ATmega328P, responsável por realizar a leitura, calcular os valores e enviar para o ESP32S3.
- `docs/`: Documentação do projeto, incluindo diagramas UML, Canvas do modelo de negócios e relatórios.


## 📝 Licença
Este projeto está licenciado sob a Licença MIT. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.

---

Desenvolvido com 💡 por [Equipe WattSync](https://github.com/usuario/WattSync) para o curso Técnico em Desenvolvimento de Sistemas.
