
# Projeto Elise

Aplicativo mobile desenvolvido em **Flutter** como Trabalho de Conclusão de Curso (TCC).
O projeto tem como objetivo oferecer uma solução prática para organização de tarefas e compromissos, integrando **bloco de notas**, **lembretes com notificações locais** e **chatbot interativo**.

---

## Funcionalidades

* Criação e edição de notas.
* Lembretes com **notificações locais**.
* Personalização de cores para cada nota/lembrete.
* Calendário integrado para gestão de tarefas.
* Chatbot interativo com integração a API externa.
* Informações extras na sidebar (ex.: clima).

---

## 🛠️ Tecnologias Utilizadas

 Tecnologias Utilizadas no Projeto Elise

- **Flutter (Dart)** – desenvolvimento mobile multiplataforma.

- **SharedPreferences** – persistência de dados locais (salvar tema, preferências etc.).
- **flutter_local_notifications + timezone** – agendamento e envio de notificações locais.
- **permission_handler** – controle de permissões no Android/iOS.
- **flutter_colorpicker** – escolha de cores personalizadas para notas/lembretes.
- **sidebarx** – barra lateral de navegação personalizada.
- **API externa de clima (weather_page.dart)** – integração com serviços externos.
- **Integração com Chatbot (chat_page_google.dart)** – consumo de API de IA (Google Gemini).
- **Dart:convert & Dart:io** – manipulação de JSON e controle de plataforma (Android/iOS).
---

## ▶ Como Executar

1. Clone este repositório:

   ```bash
    https://github.com/Leo-aab/autoagenda.git
   ```
2. Entre na pasta do projeto:

   ```bash
   cd projeto-elise
   ```
3. Instale as dependências:

   ```bash
   flutter pub get
   ```
4. Rode o app no emulador ou dispositivo físico:

   ```bash
   flutter run
   ```

---

## Status do Projeto

Em desenvolvimento – versão inicial para apresentação de TCC.

> Possuí alguns(muitos) pontos para melhorar que será lançado ao longo do tempo
---

##  Autor

**Leonardo Abreu**

* [LinkedIn](https://linkedin.com/in/leonardo-abreu)
* [GitHub](https://github.com/Leo-aab)

---

***obs***: A chave para a integração do chatbot é pessoal e por isso é neccessário ser declarada na constante `apiKey` para funcionar o aplicativo 100% 
