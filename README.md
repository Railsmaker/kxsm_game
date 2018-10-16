<h2><small>Game name: </small>Who wants to be a millionaire?</h2>
<h4><small>Игра: Кто хочет стать миллионером?</small></h4>
<img src="http://hitvid.ru/uploads/posts/2012-12/1356267451_kto-hochet-stat-millionerom.png" width="355"/>
<br />
Правила игры: <a href="https://ru.wikipedia.org/wiki/%D0%9A%D1%82%D0%BE_%D1%85%D0%BE%D1%87%D0%B5%D1%82_%D1%81%D1%82%D0%B0%D1%82%D1%8C_%D0%BC%D0%B8%D0%BB%D0%BB%D0%B8%D0%BE%D0%BD%D0%B5%D1%80%D0%BE%D0%BC%3F"> **здесь**</a>

##### 
Игра написана на языке Ruby с использованием фрейморка Ruby on Rails,<br>
предназначена для установки на собственный сайт в качестве разврекательной <br>
страницы или на персональный компьютер, с запуском в окне браузера.</p>

###
<h4>Подготовка к установке:</h4>
1. Операционная система Ubuntu 16+
2. Скачайте и установите интерпретатор Ruby 2.4  <a href="https://www.ruby-lang.org/ru/downloads/">скачать</a>

Для игры потребуется база данных: 
``` 
sudo apt update
sudo apt install sqlite3
```
Mенеджер для управления зависимостями gem'ов: 
``` 
gem install bundle
```
Феймворк для построения веб-приложений RoR: 
``` 
gem install rails
```
##
<h4>Установка игры: </h4>

Склонируйте данный репозиторий: 
``` 
sudo clone git@github.com:Raysmaker/game_KXSM.git
```
Скачайте все зависимости приложения:
``` 
bundle install
```
Создайте структуру таблиц в базе данных:
``` 
rake db:migrate
```
Создайте первоначальные данные в базе:
``` 
rake db:seed
```
##
<h4>Запуск  игры: </h4>

Старт приложения, адрес видимости: <a href="http://localhost:3000">http://localhost:3000 </a>
``` 
bundle exec rails server 
```
##
<h4> Об авторе: </h4>
Школа: <a href="http://goodprogrammer.ru/">хороший программист"</a>, студент: Алексей Ряписов

