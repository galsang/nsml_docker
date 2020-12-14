FROM nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04
RUN apt-get -y -qq update

# Install anaconda and basic python packages
# Adding wget, bzip2, sudo, and vim
RUN apt-get install -y wget bzip2 sudo vim
# Add user nsml with no password, add to sudo group
RUN adduser --disabled-password --gecos '' nsml
RUN adduser nsml sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER nsml
WORKDIR /home/nsml/
RUN chmod a+rwx /home/nsml/
#RUN echo `pwd`
# Anaconda installing
RUN wget https://repo.continuum.io/archive/Anaconda3-2020.02-Linux-x86_64.sh
RUN bash Anaconda3-2020.02-Linux-x86_64.sh -b
RUN rm Anaconda3-2020.02-Linux-x86_64.sh
# Set path to conda
#ENV PATH /root/anaconda3/bin:$PATH
ENV PATH /home/nsml/anaconda3/bin:$PATH
# Updating Anaconda packages
RUN conda update conda
RUN conda update anaconda
RUN conda update --all

# Setting pytorch envs
RUN pip install --upgrade pip
RUN pip install --upgrade torch==1.7.0
RUN pip install --upgrade transformers==3.5.1
RUN pip install --upgrade sentence-transformers==0.3.9

# Load PLMs
ENV PYTORCH_TRANSFORMERS_CACHE=/home/nsml/transformers/
RUN python -c "import transformers; transformers.AutoTokenizer.from_pretrained('bert-base-uncased'); transformers.AutoModel.from_pretrained('bert-base-uncased')"
RUN python -c "import transformers; transformers.AutoTokenizer.from_pretrained('bert-large-uncased'); transformers.AutoModel.from_pretrained('bert-large-uncased')"
RUN python -c "import transformers; transformers.AutoTokenizer.from_pretrained('roberta-base'); transformers.AutoModel.from_pretrained('roberta-base')"
RUN python -c "import transformers; transformers.AutoTokenizer.from_pretrained('roberta-large'); transformers.AutoModel.from_pretrained('roberta-large')"
RUN python -c "import sentence_transformers; sentence_transformers.SentenceTransformer('bert-base-nli-mean-tokens');"
RUN python -c "import sentence_transformers; sentence_transformers.SentenceTransformer('bert-large-nli-mean-tokens');"
RUN python -c "import sentence_transformers; sentence_transformers.SentenceTransformer('roberta-base-nli-mean-tokens');"
RUN python -c "import sentence_transformers; sentence_transformers.SentenceTransformer('roberta-large-nli-mean-tokens');"
RUN chmod -R 777 $PYTORCH_TRANSFORMERS_CACHE
