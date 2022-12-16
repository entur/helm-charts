# Changelog

## [1.4.2](https://github.com/entur/helm-charts/compare/common-v1.4.1...common-v1.4.2) (2022-12-16)


### Bug Fixes

* Add missing template block in CronJob template ([#56](https://github.com/entur/helm-charts/issues/56)) ([0ed3b82](https://github.com/entur/helm-charts/commit/0ed3b828c8c9d452d0032c3e67d7edda92d676f1))

## [1.4.1](https://github.com/entur/helm-charts/compare/common-v1.4.0...common-v1.4.1) (2022-12-09)


### Bug Fixes

* apply cron fix ([#54](https://github.com/entur/helm-charts/issues/54)) ([5836709](https://github.com/entur/helm-charts/commit/58367097d5558281172f987765c072a9d7696227))

## [1.4.0](https://github.com/entur/helm-charts/compare/common-v1.3.3...common-v1.4.0) (2022-12-09)


### Features

* Add support for running command with arguments in containers ([#51](https://github.com/entur/helm-charts/issues/51)) ([8479bed](https://github.com/entur/helm-charts/commit/8479bed8eed5d660545591ea510d889bb69edd75))

## [1.3.3](https://github.com/entur/helm-charts/compare/common-v1.3.2...common-v1.3.3) (2022-12-07)


### Bug Fixes

* allow override of postgres credentials and connection ([#49](https://github.com/entur/helm-charts/issues/49)) ([ef0b05b](https://github.com/entur/helm-charts/commit/ef0b05b49fed7ea48b8e1d5e31bc5e350e81c102))

## [1.3.2](https://github.com/entur/helm-charts/compare/common-v1.3.1...common-v1.3.2) (2022-12-06)


### Bug Fixes

* configmapRef should use release-name ([#46](https://github.com/entur/helm-charts/issues/46)) ([eb711bd](https://github.com/entur/helm-charts/commit/eb711bd1ba95581cfad9e3f5f773bedd5b9163bc))

## [1.3.1](https://github.com/entur/helm-charts/compare/common-v1.3.0...common-v1.3.1) (2022-12-05)


### Bug Fixes

* apply seccomprofile on pods ([#43](https://github.com/entur/helm-charts/issues/43)) ([4f4989f](https://github.com/entur/helm-charts/commit/4f4989f5da955ad816b870a09e83ca25f4867fff))

## [1.3.0](https://github.com/entur/helm-charts/compare/common-v1.2.9...common-v1.3.0) (2022-12-02)


### Features

* multiple ports, multiple deployments, override pdb and hpa ([#40](https://github.com/entur/helm-charts/issues/40)) ([409ddb2](https://github.com/entur/helm-charts/commit/409ddb2ab84e9a5404e427b59d67e09af08e57b2))

## [1.2.9](https://github.com/entur/helm-charts/compare/common-v1.2.8...common-v1.2.9) (2022-11-09)


### Bug Fixes

* add terminationGracePeriodSeconds ([#37](https://github.com/entur/helm-charts/issues/37)) ([b0950a5](https://github.com/entur/helm-charts/commit/b0950a51f1ea71779dbd840d7beb75bd51f95ec9))

## [1.2.8](https://github.com/entur/helm-charts/compare/common-v1.2.7...common-v1.2.8) (2022-11-08)


### Bug Fixes

* enable grpc from common chart ([#33](https://github.com/entur/helm-charts/issues/33)) ([4645c9f](https://github.com/entur/helm-charts/commit/4645c9f3a6357df81d4083b4dc893cc1afcf65cb))

## [1.2.7](https://github.com/entur/helm-charts/compare/common-v1.2.6...common-v1.2.7) (2022-10-18)


### Bug Fixes

* add pdb for forceReplicas > 1 ([#28](https://github.com/entur/helm-charts/issues/28)) ([5871ef9](https://github.com/entur/helm-charts/commit/5871ef956407dadd15f6c22122352d7da16efd07))

## [1.2.6](https://github.com/entur/helm-charts/compare/common-v1.2.5...common-v1.2.6) (2022-10-11)


### Bug Fixes

* Allow setting cloudsqlproxy resource limits via values ([#26](https://github.com/entur/helm-charts/issues/26)) ([31cc0c8](https://github.com/entur/helm-charts/commit/31cc0c87b4b52efc317daedc8e67f8e206a85f73))

## [1.2.5](https://github.com/entur/helm-charts/compare/common-v1.2.4...common-v1.2.5) (2022-09-12)


### Bug Fixes

* replicas bug and force 1 must lead to strategy recreate ([#23](https://github.com/entur/helm-charts/issues/23)) ([32ee5bb](https://github.com/entur/helm-charts/commit/32ee5bb543eaeed7f956ba7e98e3e42b3bf71ea2))

## [1.2.4](https://github.com/entur/helm-charts/compare/common-v1.2.3...common-v1.2.4) (2022-09-05)


### Bug Fixes

* enable flag for service, default on ([#21](https://github.com/entur/helm-charts/issues/21)) ([402aa04](https://github.com/entur/helm-charts/commit/402aa04a2e53d2245f179df315794a9cfc471b29))

## [1.2.3](https://github.com/entur/helm-charts/compare/common-v1.2.2...common-v1.2.3) (2022-09-01)


### Bug Fixes

* enable custom values through common.values closes [#11](https://github.com/entur/helm-charts/issues/11) ([#18](https://github.com/entur/helm-charts/issues/18)) ([84101e9](https://github.com/entur/helm-charts/commit/84101e97280dface4129cd9139bd37f3011a5f93))

## [1.2.2](https://github.com/entur/helm-charts/compare/common-v1.2.1...common-v1.2.2) (2022-08-26)


### Bug Fixes

* mulf hack bug, closes [#7](https://github.com/entur/helm-charts/issues/7) ([#16](https://github.com/entur/helm-charts/issues/16)) ([6a339f1](https://github.com/entur/helm-charts/commit/6a339f1ece522f3cb3ad23a695ed977562587f1a))

## [1.2.1](https://github.com/entur/helm-charts/compare/common-v1.2.0...common-v1.2.1) (2022-08-26)


### Bug Fixes

* enable forceReplicas to run with 1 replica in prod ([#14](https://github.com/entur/helm-charts/issues/14)) ([7c6319e](https://github.com/entur/helm-charts/commit/7c6319e0eca134c55506d768df121268a9bd06b3))

## [1.2.0](https://github.com/entur/helm-charts/compare/common-v1.1.0...common-v1.2.0) (2022-08-23)


### Features

* add environment label ([#10](https://github.com/entur/helm-charts/issues/10)) ([c8d7a90](https://github.com/entur/helm-charts/commit/c8d7a90a5414b216314b940c2969d82842cdd18e))

## [1.1.0](https://github.com/entur/helm-charts/compare/common-1.0.2...common-v1.1.0) (2022-07-28)


### Features

* add gha workflows ([#6](https://github.com/entur/helm-charts/issues/6)) ([7ce6d29](https://github.com/entur/helm-charts/commit/7ce6d2987eb027f176a5836e81ed61e7c12066ff))
