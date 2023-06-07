Подготовить terraform скрипты для поднятия кластера из 3х нод в AWS EKS.
 Настроить пайплайны для автодеплоя в кубер после коммита/мерджа кода.
 Приложение можно использовать WordPress.
 Для автодеплоя можно исользовать Gitlab CI и/или Github actions и/или CodePipelne.
 Все изменения в инфраструктуре должны происходить только через коммита/merge.
 В качестве базы данных для WordPress можно использовать либо RDS либо на маленьком инсансе подготовить MariaDB(будет круче если будет PostgreSQL).
Итого должно быть:
- Репозитрий с приложением
- Репозиторий с terraform
- CI/CD для приложения
- CI/CD для инфраструктуры
- База данных.

