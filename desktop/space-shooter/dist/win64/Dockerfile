FROM frag_core
MAINTAINER Zachary Carter "carterza@gmail.com"

RUN apt-get update -qq

RUN apt-get install --yes \
  unzip \
  wget \
  mingw-w64 && \
apt-get clean --yes

RUN cd /frag/vendor/bgfx && genie --with-shared-lib --gcc=mingw-gcc --os=windows --platform=x64 gmake
ENV MINGW=/usr
RUN cd /frag/vendor/bgfx/.build/projects/gmake-mingw-gcc && make config=release64 bgfx-shared-lib
RUN cd /frag && nimble install -y

COPY . /space-shooter
RUN cd /space-shooter && mkdir -p ./bin/win64 && cd ./bin/win64
CMD cd /space-shooter && \ 
  nim c -d:distWin64 -d:release -o:./bin/win64/space_shooter.exe ./src/space_shooter.nim && \
  cd ./bin/win64 && \ 
  wget https://www.libsdl.org/release/SDL2-2.0.5-win32-x64.zip && \ 
  unzip -j SDL2-2.0.5-win32-x64.zip && \ 
  rm SDL2-2.0.5-win32-x64.zip && \ 
  wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.1-win32-x64.zip && \ 
  unzip -j SDL2_image-2.0.1-win32-x64.zip && \
  rm SDL2_image-2.0.1-win32-x64.zip && \
  wget https://github.com/fragworks/frag-deps/raw/master/win64/OpenAL32.dll && \
  cp /frag/vendor/bgfx/.build/win64_mingw-gcc/bin/bgfx-shared-libRelease.dll /space-shooter/bin/win64
