cwd="$PWD"
docker build -f dist/win64/Dockerfile -t win64 .
docker run -it -v "$cwd/bin/:/space-shooter/bin" win64
cp -r assets bin/assets
zip bin/space-shooter.zip bin/win64/** bin/assets/**