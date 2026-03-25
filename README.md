# Entur helm charts

Helm charts for use in the Entur organisation.

## Quick Start

Browse our [examples/common](./examples/common) folder for quick examples to get started.

## [Documentation](./charts/common/#common)

Full documentation on each chart you can find in the [charts/](./charts/) folders.

## IDE Support

The chart includes a [JSON Schema](./charts/common/values.schema.json) for `values.yaml` validation. This gives you autocompletion, inline documentation, and error highlighting in your IDE.

### VS Code

Install the [YAML extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) and add this to your `values.yaml`:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/entur/helm-charts/main/charts/common/values.schema.json
common:
  app: my-app
  ...
```

Or configure it in `.vscode/settings.json`:

```json
{
  "yaml.schemas": {
    "https://raw.githubusercontent.com/entur/helm-charts/main/charts/common/values.schema.json": ["values*.yaml", "env/values*.yaml"]
  }
}
```

### JetBrains (IntelliJ / GoLand)

Go to **Settings → Languages & Frameworks → Schemas and DTDs → JSON Schema Mappings**, add a new mapping:
- **Schema URL**: `https://raw.githubusercontent.com/entur/helm-charts/main/charts/common/values.schema.json`
- **File path pattern**: `values*.yaml`

Note: Since the chart is used as a dependency, your values are nested under `common:`. The schema validates the properties under that key.

## Upgrading

See [UPGRADE.md](UPGRADE.md) for migration guides between major versions.

## Contributing

For guidance on how to contribute, see our [contribution documentation](CONTRIBUTING.md).

## Issues

Found a bug? Please [file an issue](https://github.com/entur/helm-charts/issues)!
Or contact us in the #talk-plattform slack channel.
