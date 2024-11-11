# WattSync - Wattímetro Inteligente

O WattSync é um projeto de desenvolvimento de um wattímetro multifuncional que visa atender à crescente demanda por tecnologias de medição e gerenciamento de consumo elétrico em residências. Este dispositivo foi projetado para promover segurança, praticidade e eficiência, oferecendo uma série de funcionalidades que auxiliam no controle do uso de energia.

## 📋 Objetivo do Projeto
Desenvolver um dispositivo capaz de monitorar o consumo de energia elétrica em residências brasileiras, proporcionando acessibilidade e promovendo o controle de gastos com foco em sustentabilidade. O WattSync é voltado para auxiliar os usuários no entendimento e gerenciamento de seu consumo energético, além de fornecer recursos para desligamento remoto e proteção contra sobrecargas.

### Funcionalidades
- Medição de corrente, tensão, potência e frequência com precisão.
- Monitoramento remoto via aplicativo com conexão Wi-Fi.
- Indentificação do tipo de rede elétrica.
- Desligamento automático em caso de sobrecarga.
- Desligamento automático em caso de subtensão ou sobretensão.
- Aviso sonoro em caso de desligamento.
- Limite de consumo configurável.
- Display para a visualização dos dados no própio dispositivo.
- Programação de horários para ligar e desligar os dispositivos.
- Interface amigável para visualizar e interpretar dados de consumo.
- Pode ser utilizado em todas as redes elétricas brasileiras.
## 🛠️ Tecnologias Utilizadas

### Hardware
- **Microcontroladores:** ESP32S3 (WROOM 1) e ATmega328P.
- **Sensores de Corrente e Tensão:** ACS712 30A e Divisor de Tensão.
- **Componentes de Proteção:** Varistor 14D561K, Fusível de Queima Rápida de 25A e Diodo Zener 1N4733A.

### Software
- **Frontend do Aplicativo:** Flutter.
- **Backend:** C (para o ESP32 e ATmega328P).
- **Armazenamento de Dados:** SQLite para o aplicativo.
- **Ferramentas de Design:** Canva, Figma, Paint, Fritzing, KiCad, Astah UML.
- **IDE:** Visual Studio Code, Arduino IDE, Google IDX.
- **Versionamento de Código:** Git, Github.

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

3. Conecte o ESP32 ao computador e faça upload do código na pasta `ESP32S3` para o ESP32S3 usando a Arduino IDE.
    Selecione a placa "ESP32S3 Dev Module", em outras variações pode não funcionar corretamente.

4. Conecte o ATmega328P ao computador utilizando um gravador UART e faça upload do código na pasta `ATMEGA328P` usando a Arduino IDE.

5. Execute o aplicativo:
    ```bash
    flutter run
    ```

6. No aplicativo, insira o código do produto para acessar as funcionalidades de monitoramento e controle.


## 💡 Estrutura do Projeto

- `app/`: Código do aplicativo Flutter, incluindo widgets e gráficos.
- `wattmeter/ESP32S3/`: Código para o ESP32, responsável por capturar os dados do ATmega328P e enviar ao aplicativo.
- `wattmeter/ATMEGA328P/`: Código para o ATmega328P, responsável por realizar a leitura, calcular os valores e enviar para o ESP32S3.
- `docs/`: Documentação do projeto, incluindo diagramas UML, Canvas do modelo de negócios e relatórios.


Desenvolvido por [Equipe WattSync](https://github.com/WattSync) para o Trabalho de Conclusão de Curso do Técnico em Desenvolvimento de Sistemas da ETEC Raposo Tavares.


### 👷👷‍♀️ Membros da Equipe

- [Beatriz// ](https://www.linkedin.com/in/beatrizbernardess): Responsável pelo desenvolvimento do software e das apresentações.
- [Bruno// ](https://github.com/usuario/WattSync): Responsável pelo desenvolvimento do website.
- [Camila](https://www.linkedin.com/in/camila-lourenco23032007): Responsável pelo desenvolvimento do software e documentação do projeto.
- [Hércules da S. Pereira](https://www.linkedin.com/in/herculessp): Responsável pelo desenvolvimento do firmware e hardware do dispositivo.
- [Keven Wanne//](https://github.com/usuario/WattSync): Responsável pelo desenvolvimento do software.
- [Yasmin E. P. da Silva](https://www.linkedin.com/in/yasminpilla): Responsável pelo desenvolvimento do software e documentação do projeto.


## 📝 Licença

Este projeto está licenciado sob a Licença GPL-3.0. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.