# AngelOS Community Store

[English version](README.md) | Русская версия

Независимый плагин AngelOS для поиска, установки, обновления и удаления
community-плагинов через нативную систему AngelOS.

## Установка

Установщик Python:

```bash
curl -fsSL -o /tmp/install-community-store.py \
  https://raw.githubusercontent.com/futureUnd1ground/angelos-community-store/main/install-community-store.py
python3 /tmp/install-community-store.py
```

Установщик Fish:

```fish
curl -fsSL -o /tmp/install-community-store.fish \
  https://raw.githubusercontent.com/futureUnd1ground/angelos-community-store/main/install-community-store.fish
and fish /tmp/install-community-store.fish
```

Установщик скачивает проверенный release по HTTPS, проверяет архив и manifest,
устанавливает Store в `~/.config/angelos/plugins`, создаёт команду
`community-store`, добавляет `~/.local/bin` в PATH Fish и перезапускает AngelOS.

## TUI

Запуск:

```bash
community-store
```

Стрелки или `j/k` перемещают выбор, `Enter` устанавливает или обновляет,
`d` удаляет, `U` обновляет плагины, `s` обновляет сам Store, `r` обновляет
registry, `/` ищет, `a` показывает все, `i` установленные, `v` обновления,
`q` закрывает интерфейс.

После успешной установки или обновления плагина оболочка AngelOS автоматически
перезапускается, чтобы загрузить его компоненты. При массовом обновлении она
перезапускается один раз после завершения очереди.

## Установка из меню «Выполнить»

Открой поиск приложений (`Mod+Space`), введи `plugins` и часть названия,
автора, описания или тега. Выбери действие `Install`, `Update` или `Remove`.
Удаление использует штатное перемещение плагина в корзину AngelOS.

Страница Store находится в **Настройки → Плагины → Community Store**. После
обновления оболочка перезапускается автоматически, чтобы подхватить компоненты.

## Registry

По умолчанию используется публичный registry:

`https://github.com/futureUnd1ground/angelos-community-registry`

Плагин появляется в Store только после статуса `approved`. Store проверяет
HTTPS, manifest, ID и версию, безопасные пути архива и размер ZIP.

## Публикация

Инструкция разработчика находится в registry:

https://github.com/futureUnd1ground/angelos-community-registry/blob/main/CONTRIBUTING.ru.md
