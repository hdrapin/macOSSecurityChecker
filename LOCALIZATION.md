# macOS Security Checker - Localization Guide

## Supported Languages

- 🇬🇧 **English** (en) - Default
- 🇫🇷 **French** (fr)

## Using Different Languages

### Command Line
```bash
# English (default)
./macOSSecurityChecker.release.swift

# French
./macOSSecurityChecker.release.swift --lang fr
# or
./macOSSecurityChecker.release.swift --language francais

# Combined with other options
./macOSSecurityChecker.release.swift --lang fr --json
./macOSSecurityChecker.release.swift --lang en --csv
```

## Language Implementation

The application supports multilingual output by detecting the `--lang` flag and adjusting:
- Section headers
- Status messages
- Recommendations
- Help text
- Error messages

## Translation Strings

### English (en)
- Headers: "FIREWALL & NETWORK SECURITY"
- Status: "ENABLED", "DISABLED", "Unknown"
- Recommendations: "Recommendation", "Action", "Impact"
- Score: "EXCELLENT", "GOOD", "FAIR", "NEEDS ATTENTION", "CRITICAL"

### French (fr)
- Headers: "PARE-FEU ET SÉCURITÉ RÉSEAU"
- Status: "ACTIVÉ", "DÉSACTIVÉ", "Inconnu"
- Recommendations: "Recommandation", "Action", "Impact"
- Score: "EXCELLENT", "BON", "MOYEN", "ATTENTION REQUISE", "CRITIQUE"

## Adding New Languages

To add a new language:

1. Define language constants in the code
2. Create translation mappings for:
   - Section headers
   - Status indicators
   - Check descriptions
   - Recommendations
   - Help text

3. Update language detection logic
4. Test output with new language

## Language Detection Priority

1. Command-line argument: `--lang fr`
2. Environment variable: `LANG=fr_FR.UTF-8`
3. System locale: Automatically detected from macOS settings
4. Default: English

## Example Output Comparison

### English
```
🔥 FIREWALL & NETWORK SECURITY (9/9 PASSED)
  ✓ Firewall Enabled                   ENABLED
  ✗ SSH Enabled                        ENABLED (⚠️ review if needed)
```

### French
```
🔥 PARE-FEU ET SÉCURITÉ RÉSEAU (9/9 RÉUSSI)
  ✓ Pare-feu activé                    ACTIVÉ
  ✗ SSH activé                         ACTIVÉ (⚠️ à vérifier si nécessaire)
```

## Help Text by Language

### English
```
Usage: macOSSecurityChecker [OPTIONS]

OPTIONS:
  --help, -h              Display this help message
  --version               Show version information
  --lang LANGUAGE         Set language (en, fr)
  --json                  Output in JSON format
  --csv                   Output in CSV format
  --verbose, -v           Show detailed information
```

### French
```
Utilisation: macOSSecurityChecker [OPTIONS]

OPTIONS:
  --aide, -h              Afficher ce message d'aide
  --version               Afficher les informations de version
  --langue LANGUE         Définir la langue (en, fr)
  --json                  Sortie au format JSON
  --csv                   Sortie au format CSV
  --verbose, -v           Afficher les informations détaillées
```

## Current Implementation Status

- ✅ English fully supported
- ✅ French fully supported (compatible with terminal output)
- ⚠️ JSON output maintains English keys (for compatibility)
- ⚠️ CSV output can be localized for headers

## Notes

- Default language is English for better compatibility
- Users can override with `--lang fr` flag
- Terminal color output is language-independent
- JSON keys remain in English for programmatic access
- CSV headers can be translated based on locale

## Future Enhancements

- [ ] Spanish (es) support
- [ ] German (de) support
- [ ] Japanese (ja) support
- [ ] Localized recommendation messages
- [ ] Locale-aware date/time formatting
- [ ] RTL language support
