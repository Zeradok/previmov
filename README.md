# previmov

*previmov* é um trabalho colaborativo coordenado pelo Professor [Regis A. Ely](http://regisely.com) e desenvolvido com a ajuda dos alunos do [Mestrado em Economia Aplicada](http://wp.ufpel.edu.br/ppgom/) e do Curso de Graduação em Economia da Universidade Federal de Pelotas (UFPel).

O objetivo deste trabalho é desenvolver algoritmos para coleta, análise e previsão de preços de imóveis baseado em suas características. Inicialmente a análise será aplicada para a cidade de Pelotas-RS, podendo ser estendida para outras cidades futuramente.

*previmov* é um trabalho em progresso. No momento este repositório inclui:

1. Rotina em Python 2.7 para coleta de cerca dos imóveis à venda na cidade de Pelotas, disponibilizados em um arquivo csv;

2. Script `dados.R` e `dados_novos.R` para o carregamento dos dados e filtragem dos outliers. O primeiro faz a filtragem manualmente para o arquivo `imoveis_pel.csv`, enquanto que o segundo utiliza um algoritmo de detecção de outliers e pode ser aplicado para qualquer atualização da base;

3. Scripts `tabela.R` e `graficos.R` para a análise dos dados em [R](https://www.r-project.org/);

4. Dois aplicativos interativos construídos através do framework [shiny](http://shiny.rstudio.com/), um para a análise visual dos dados e outro para construção de tabelas descritivas;

5. Scripts `regressoes.R`, `gradientdescent.R` e `neuralnetwork.R` que implementam modelos de previsão de preços de imóveis no R, bem como métodos de validação;

6. Script `train.R` que utiliza a função train do pacote [caret](https://cran.r-project.org/web/packages/caret/index.html) para estimar diversos modelos de previsão e escolher o melhor após compará-los através de 10-fold cross validation. 

# Como utilizar

No momento você pode acessar os aplicativos interativos criados no R com o pacote shiny (os últimos dados disponibilizados são de 13 de fevereiro de 2018). Para isso abra a sua sessão do R e digite:

```r
install.packages("shiny") # Instale o pacote shiny caso não o tenha
library(shiny)
runGitHub("previmov", "regisely", subdir="graphs")
runGitHub("previmov", "regisely", subdir="tables")
```

Você também pode clonar este repositório para testar todos os scripts em R utilizando o seguinte comando no seu terminal:

```
git clone https://github.com/regisely/previmov.git
```
Note que é este comando irá criar uma pasta com nome previmov no diretório atual contendo todos os arquivos. É necessária a instalação do [git](https://git-scm.com/downloads) antes. Caso você não queira instalar o git pode baixar todos os arquivos zipados [neste link](https://github.com/regisely/previmov/archive/master.zip).

# Como contribuir

Se você deseja contribuir com este projeto você pode:

1. Submeter [issues](https://github.com/regisely/previmov/issues) neste site ao identificar problemas e/ou sugestões relevantes;

2. Criar novos scripts ou modificar arquivos existentes utilizando o git (acesse o arquivo [git-info.md](git-info.md) para mais informações);

3. Enviar sugestões ou contribuições através do email regisaely@gmail.com. 

Caso você queira saber mais especificamente onde contribuir você pode acessar uma [lista de tarefas](TODO.md) pendentes que está sendo constantemente atualizada.

# Copyright

No momento este projeto não se enquadra na definição de "software livre". Ele está licenciado sob [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported](https://creativecommons.org/licenses/by-nc-sa/3.0/). Esta licença permite que você copie, redistribua e adapte qualquer código encontrado aqui, porém você não pode usá-los com intuito comercial e qualquer obra derivada deve atribuir o crédito original elencando as mudanças que foram feitas, além de estar licenciada sob os mesmos termos. Isto vale também para a utilização dos dados disponibilizados neste repositório.