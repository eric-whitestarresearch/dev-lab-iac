git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc


asdf plugin-add kubectl https://github.com/asdf-community/asdf-kubectl.git
asdf install kubectl 1.30.4
asdf global kubectl 1.30.4

mkdir ~/.kube

asdf plugin-add kubectx https://github.com/virtualstaticvoid/asdf-kubectx.git
asdf install kubectx latest
asdf global kubectx latest

alias k="kubectl"
alias kgp="kubectl get pods"
alias kgpa="kubectl get pods -A"
alias kctx="kubectx"
alias kns="kubens"

asdf plugin-add helm https://github.com/Antiarchitect/asdf-helm.git
asdf install helm latest
asdf global helm latest

asdf plugin-add stern https://github.com/looztra/asdf-stern
asdf install stern latest
asdf global stern latest
