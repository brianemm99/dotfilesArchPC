FROM archlinux:base-devel

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# chezmoi, mise, shfmt from the repos; qt6-declarative gives qmllint/qmlformat/qmlls
# Package cache is cleared but sync DBs are kept, so `pacman -Si <pkg>` works
# for checking package names in the install script.
RUN pacman -Syu --noconfirm --needed \
      git openssh less \
      chezmoi mise shfmt qt6-declarative \
 && rm -rf /var/cache/pacman/pkg/*

RUN groupadd -g ${USER_GID} ${USERNAME} \
 && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

ENV PATH="/home/${USERNAME}/.local/share/mise/shims:/usr/lib/qt6/bin:${PATH}"

USER ${USERNAME}

RUN curl -fsSL https://mise.run | sh
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# shellcheck via mise: the pacman package drags in a pile of haskell-* libs
RUN echo 'eval "$(mise activate bash)"' >> ~/.bashrc \
 && mise use -g shellcheck
