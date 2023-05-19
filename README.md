# LoLWiki-LuaAnalyzer
Данный проект представляет собой один из нескольких инструментов, созданных для облегчения работы с русскоязычной Вики по League of Legends, созданной на платформе Fandom.

Этот проект позволяет отслеживать зависимости между модулями Lua. В ходе работы с помощью API MediaWiki вызывается список всех модулей из https://leagueoflegends.fandom.com/ru/ , после чего из полученного списка исключаются все модули, содержащие в своем названии "/data" (таблицы БД) и "/doc" (файлы документации), а затем каждый модуль анализируется на вызов других модулей (это действие происходит при помощи встроенных функций `require` или `mw.loadData`). Полученный в ходе работы список отправляется дальше для форматированного вывода в консоль или внешний документ.

Стоит отметить, что эта программа не проводит полноценный семантический анализ кода Lua, а руководствуется лишь набором регулярных выражений. Из-за этого ограничения (пока что) нельзя достоверно узнать об использовании модулей, чьи имена вычисляются в процессе исполнения кода Lua.

# For English-speaking users
This project is one of tools created to ease administration of Russian League of Legends Wiki on Fandom platform.

This project checks dependency links between Lua modules. It requests list of modules from https://leagueoflegends.fandom.com/ru/ via MediaWiki API, excludes all modules containing "/data" (table-like DB) and "/doc" (documentation) and then analyzes every module for calling of other modules (this action is performed via built-in functions `require` and `mw.loadData`). The result is sent further for formatted output in console or text file.

One should notice, that this program does not perform full semantic analysis of Lua code, and only uses a set of regexes. Due to this limitation it's impossible (for now) to genuinely get information about module usage, which names are calculated during Lua code runtime.
