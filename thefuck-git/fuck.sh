fuck() {
	TF_CMD=$(TF_SHELL=zsh thefuck "$(fc -ln -1)") && eval "$TF_CMD"
}
