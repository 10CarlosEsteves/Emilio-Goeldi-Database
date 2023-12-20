# Emilio-Goeldi-Database
<h2>Resumo</h2>

<p>
  O seguinte projeto foi desenvolvido como parte de uma avaliação da disciplina de banco de dados no CESUPA (Centro Universitário do Estado do Pará), ministrada pelo professor <a href="https://www.linkedin.com/in/isaac-elgrably-8a3440115/">Isaac Elgrably</a>. O projeto consistiu na construção de um banco de dados a partir de um arquivo CSV (Comma Separated Values), proveniente da base de dados do Museu Paraense Emíliog Goeldi, com o título de Annelida Collection. Ao analisar os dados presentes no CSV, a missão foi compreender como esses dados estavam relacionados entre si e como o modelo Entidade-Relacionamento deveria ser aplicado nesse contexto. Uma vez construído o modelo E-R, ele foi implementado no PostgreSQL. Após a implementação do banco de dados, os dados do arquivo CSV foram tratados e, por fim, inseridos no banco. A etapa de inserção no banco de dados foi realizada tanto manualmente quanto automaticamente, utilizando a linguagem de programação Python para tratar erros e eliminar redundâncias de dados.
</p>

<p>
Destaca-se, na fase de inserção, que o resultado final foi a geração de um arquivo .SQL em Postgre com os dados tratados, pronto para ser inserido no banco. Na penúltima etapa, foram criadas automações para o banco de dados, como triggers, views e procedures, visando aprimorar o funcionamento do banco. Finalmente, um dashboard no Power BI foi desenvolvido para exibir, de maneira intuitiva e visual, os dados presentes no banco de dados criado.
</p>

<h2>Banco de Dados PostgreSQL</h2>

<p>
  A implementação do banco de dados deveria ser robusta, não redundante, intuitiva, de fácil manutenção e que oferecesse flexibilidade aos dados inseridos por pesquisadores. Através desses pré-requisitos, o banco de dados final seguiu a risca as formas normais e as implementações de automações comos triggers, views e procedures para melhor funcionamento. O resultado pode ser visualizado na pasta <b>Banco de dados PostgreSQL</b>. Para melhorar a funcionalidade dos scripts, execute em ordem: tabelas, triggers & functions & views, inserts, testes das automações. O resultado do modelo E-R com os dados presentes no arquivo CSV pode ser visualizado parcialmente na imagem abaixo:
</p>
<img src="Imagens/Banco de Dados/Modelo E-R Parcial.png">

<h2>Dashboard Power BI</h2>

<p>
  Ainda como parte da lauda do projeto, um dashboard em Power BI foi criado para melhor visualização dos dados de Annelida por partes dos pesquisadores. A tecnologia do Power Bi foi a escolha adequada para o projeto devido a sua facilidade de implementação e seus recursos gráficos que permitiram a construção ágil, intuitiva e da melhor forma possível. O dashboard contém informações úteis como dois mapas(um mapa de densidades 3D e um mapa normal da Azure), um gráfico de pizza com os locais das pesquisas e um gráfico de rosquinha com a quantidade de táxons etc. O dashboard é um arquivo do tipo pbix e pode ser encontrado e baixado dentro da pasta <b>Dashboard Power BI</b>. Abaixo, uma amostra parcial do dashboard:
</p>
<img src="Imagens/Dashboard Power BI/Dashboard Goeldi Parcial.png">

<h2>Créditos</h2>
<p>Destaco a equipe por trás da implementação deste projeto. Somos a NextEvo</p>
<ul>
  <li>Carlos Henrique Miranda Esteves</li>
  <li>Lucas Almeida Miralha de Figueiredo</li>
  <li>Lucas Andrey Nunes de Aragão</li>
  <li>Thiago Teixeira França</li>
</ul>


