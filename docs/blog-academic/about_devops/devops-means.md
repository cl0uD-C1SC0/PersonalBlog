# DevOps na minha visão 

<p>Quando comecei a entrar no mundo do DevOps, eu me deparei com muitas tecnologias e diversas possibilidades, apesar se parecer ser complexo no início, eu sintia que deveria tentar. Por se tratar de uma área "nova" naquele momento (meados de 2021-2022), eu decidi me dedicar quase que 100% do meu tempo a estudar profundamente DevOps.</p>

<p>No ínicio dos estudos, confesso que comecei dedicando-se mais na parte técnico sem entender o conceito por trás daquilo que estava fazendo, e de cara, já vou recomendar que essa é a pior ideia possível. O Conceito existe literalmente para se criar uma ideia do que se trata determinado assunto ou ferramenta, em DevOps isso não é diferente, portanto neste artigo, escrito por mim e revisado por, mim também, vou apresentar o que é DevOps na minha visão e alguns conceitos que eu considero de extrema importância.</p>

## O que é DevOps

<p>Para começarmos a entender este mundo das automações, precisamos entender o que é DevOps e do que se trata. </p>

<p>DevOps é uma metodologia, ou melhor, cultura, que se baseia 100% no ciclo de vida de desenvolvimento de software e que une essas práticas com as operações (TI). A ideia principal por trás é criar uma espécie de "ponte da união" entre esses dois times, mas como isso surgiu? </p>

<p>Bom, era uma vez dois times, um de desenvolvimento e o outro de operações. O Time de desenvolvimento precisava implementar a todo momeno alterações nas aplicações, já o time de operações, como efetuava algumas coisas manuais, não tinha muita agilidade ou até mesmo disponibilidade para atuar nas demandas, acontece que, isso começava a gerar uma certa frustração por assim dizer nos desenvolvedores, por conta que eles não conseguiam ver em produção suas alterações, não em um tempo hábil, portanto, surgiu a cultura DevOps</p>


<p>O movimento DevOps surgiu e começou a tomar uma forma entre os anos de 2007 e 008, a ideia principal era integrar esses dois times (desenvolvimento e operações) de uma forma mais eficiente. Surgiu como uma resposta à necessidade de melhorar a colaboração, comunicação entre as equipes e principalmente aumentar a agilidade dos processos. Desde então, a cultura DevOps começou a se moldar fortemente já atrelada a metodologias ágeis e processos mais rápidos impactando por exemplo o ciclo de vida de desenvolvimento de software (SDLC).
<br><br>
Portanto, quando te perguntarei o que é DevOps, uma boa resposta seria: É uma cultura que tem o objetivo de melhorar a colaboração e comunicação entre os times de desenvolvimento e operações.</p>


## Conceitos sobre DevOps

<p>Essa parte confesso para você, caro leitor, que no início de minha carreira eu basicamente, como posso dizer, a pulei, eu não procurei me informar sobre os conceitos naquele momento, tudo o que eu queria era arrumar um trabalho na área e daí começar a ganhar muito conhecimento técnico. Bom, se eu tivesse "sabido" sobre esses conceitos, em alguns problemas que vieram a ter no meu primeiro trabalho como DevOps, talvez não teriam ocorrido.</p>

<p>Conceitos que vamos ver por aqui: </p>
- Pipeline
- O que é Integração Contínua (Continuous Integration)
- O que é Entrega Contínua (Continuous Delivery)
- O que é Implantação Contínua (Continuous Deploy)
- Cultura
- Automação
- Monitoramento
- Controle de versões
- Infraestrutura como código, contêineres. 

---
### Pipeline
>Esse conceito eu decidi ser o primeiro por conta que é importante. Uma pipeline é como se fosse uma esteira de produção de um carro, cada parte da esteira é responsável por uma parte do carro. No contexto de TI, cada parte da esteira é responsável por uma etapa de desenvolvimento do software, por exemplo: baixar o código, rodar os testes unitários, analisar o código (Sonarqube por exemplo), efetuar o build e por fim deploy.
<br>

### Integração Contínua (CI)
> Consiste em basicamente pegar qualquer alteração no repositório de código do desenvolvedor e efetuar testes, builds e outros processos de formas automática utilizando por exemplo Shellscripting ou outra linguagem de programação como o Python.
<br>

### Entrega Contínua (CD)
> Nesta parte da pipeline, é basicamente, após todos os processos de CI forem executados sem falhas desde de segurança até de testes unitários por exemplo, automaticamente o código sera implementado em um ambiente de teste, homologação ou até mesmo produção, PORÉM, é necessário uma aprovação MANUAL.
<br>

### Implantação Contínua
> Segue a mesma ideia do tópico anterior (Entrega Contínua) porém, a aprovação aqui acontece de forma AUTOMÁTICA. E sim, isso aumenta muito a agilidade, mas futuramente vocês vão ver que tem seus prós e contras dessa parte do processo.
<br>

### Cultura
> A principal função de um engenheiro DevOps é facilitar a comunicação entre os times de desenvolvimento e operações, e isso pode ser feito de várias maneiras, não apenas criando Pipelines para implementar o software, mas facilitando a vida do carinha da infra por exemplo. Portanto, sua responsabilidade é auxiliar o desenvolvedor para que ele foque na sua principal função: Desenvolver. Já o operador (ou time de operações), você pode ajudar por exemplo, passando informações de consumo da aplicação, ajudar a criar um monitoramento, implementar uma infraestrutura como código. 
```bash
echo "OBS: Em alguns casos, o DevOps pode ser o time de operações como um todo!"
```
<br>

### Automação
> Uma das ideias do DevOps também é reduzir os erros humanos, por isso existe uma pipeline que faz a implementação de um software, a Pipeline garante isso (claro, dependendo de como você a estruturou). Portanto, eu me considero um cara preguiçoso no sentido de fazer trabalhos manuais, se for possível automatizar, é óbvio que vou por esse caminho.
<br>

### Monitoramento
> O DevOps também pode atuar na parte do monitoramento, mas, contando um pouco de minha experiência, quando o time na qual eu trabalhava tentou "puxar" a responsabilidade do monitoramento, recebemos um não logo de cara, portanto focamos em monitorar recursos essesenciais como consumo de recursos cluster kubernetes, pipelines, logs. Também tem uma parte que eu acho muito interessante aqui que é o Service Discovery, mas isso é melhor explicar em um projeto pessoal. 
<br>

### Controle de versões
> A ferramente utilizada para controle de versões pode variar de empresa para empresa, desde custo até facilidade na curva de aprendizagem mas todas tem o mesmo objetivo, versionar o código do desenvolvedor, mantendo versões antigas no histórico e com possibilidades de fazer um rollback mais rápido (em DevOps existe maneiras filés de fazer isso, ArgoCD ta aí pra isso.)
<br>

### Infraestrutura como código (IaC)
> Isso é o ouro de uma infraestrutura, imagina você manter e gerenciar uma infraestrutura inteira via código utilizando por exemplo o Terraform, isso agiliza muito, até mesmo quando um provedor de nuvem inteiro cair, com IaC você migra tudo para outro provedor de forma rápida.
<br>
<br>

## Stack técnica

<p align="center">Observe a imagem abaixo</p>
<a align="center"><img src="../../../assets/stack_tecnica.png"></a>
<br>

<p>Você precisa saber de tudo o que está na imagem? Não, é óbvio que não. Mas você precisa conhecer o conceito de cada etapa, por exemplo, observe a seta que aponta a parte de Deploy, as ferramentas ou serviços tem a "mesma" funcionalidade, o mesmo conceito por trás, que é implementar o seu software da maneira que você preferir, cada uma tem uma facilidade, mas o conceito é o mesmo.</p>

<p>Vou dar exemplo de ferramentas para fazer uma Pipeline: Github Actions, Jenkins, Google Cloud Build, AWS Code Build. </p>
<p>O que essas ferramentas tem em comum? Elas tem o mesmo conceito por trás e a mesma ideia, criar uma pipeline para automatizar a implementação de um software ou infrestrutura, cada uma tem sua particularidade, mas não muda o fato de terem a mesma ideia.</p>


<h2 align="center">Conclusão</h2>

<p>DevOps não é um bixo de sete cabeças e extremamente complexo de se aprender. Assim como em DevOps ou qualquer coisa na área tecnológica, se você domina o conceito, basta escolher a ferramenta para aplicar a solução que você deseja, escolha a que se enquadre melhor seja em custo, facilidade de aprendizado, robustez, seja o que for, mas antes domine o conceito.</p>

<p>Eu gosto muito da área de DevOps e SRE (Site Reability Engineering), portanto, estarei sempre que possível, postanto conteúdo técnico aqui de soluções para problemas que eu tiv e principalmente meus projetos pessoais, estes serão todos feitos com uma documentação para que você mesmo execute e entenda o que está acontecendo.</p>

---

## Conecte-se comigo!
<a href="https://www.linkedin.com/in/jgsiqueiraa/">
<img src="https://img.shields.io/badge/-LinkedIn-0A66C2?logo=linkedin&logoColor=white&style=for-the-badge" />
</a>