polkit-kde-agent is based on polkit-kde-agent [gitlab](https://invent.kde.org/plasma/polkit-kde-agent-1) 


## Features
 
* Virtual secure keyboard

* Run on JingOS platform

* Brand new UI & UE with JingOS-style , based on JingUI Framework

* Support keyboard & touchpad & mouse & screen touch

* All keys support pressed / hovered effects

* Well-designed interface material:

  * Font
  * Icon
  * Picture
  


## Links

* Home page: https://www.jingos.com/

* Project page: https://invent.kde.org/jingosdev/polkit-kde-agent-1

* Issues: https://invent.kde.org/jingosdev/polkit-kde-agent-1/issues

* Development channel: https://forum.jingos.com/



## Dependencies

* Qt5 

* Cmake

* KI18n

* Kirigami (JingOS Version)

* DBusAddons

* PolkitQt5-1

* PlasmaQuick



## Build

To build polikit-kde-agent from source on Linux, execute the below commands.



### Compile

```sh
cd polikit-kde-agent
mkdir build
cd build
cmake ..
make -j$(nproc)
```



#### Run

```
bin/polikit-kde-agent
```



#### Install

```
sudo make install
```

