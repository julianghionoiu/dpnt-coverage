package tdl.datapoint.coverage.processing;



import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public enum Language {
    HMMM("hmmm", Arrays.asList("Hmmm", "test"), "HmmmLang"),
    CSHARP("csharp", Collections.singletonList("C#"), "C#"),
    FSHARP("fsharp", Collections.singletonList("F#"), "F#"),
    VBNET("vbnet", Arrays.asList("VB", "VB.NET"), "Visual Basic"),
    JAVA("java", "Java"),
    SCALA("scala", "Scala"),
    RUBY("ruby", "Ruby"),
    PYTHON("python", "Python"),
    JAVASCRIPT("nodejs", Arrays.asList("Javascript", "JS"), "Javascript"),
    ;

    private final String languageId;
    private final java.util.List<String> alternativeNamesLowercase;
    private final String reportedLanguageName;

    Language(String key, String reportedLanguageName) {
        this(key, Collections.emptyList(), reportedLanguageName);
    }

    Language(String languageId, List<String> alternativeNamesCaseInsensitive, String reportedLanguageName) {
        this.languageId = languageId;
        this.alternativeNamesLowercase = alternativeNamesCaseInsensitive
                .stream().map(String::toLowerCase).collect(Collectors.toList());
        this.reportedLanguageName = reportedLanguageName;
    }

    public static Language of(String text) throws IllegalLanguageException {
        String trimmedAndLowercaseText = text.trim().toLowerCase();
        return Arrays.stream(Language.values())
                .filter(language -> language.languageId.equals(trimmedAndLowercaseText) ||
                        language.alternativeNamesLowercase.contains(trimmedAndLowercaseText))
                .findFirst().orElseThrow(() -> new IllegalLanguageException("Not a valid language:"+text));
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getReportedLanguageName() {
        return reportedLanguageName;
    }
}
