package tdl.datapoint.coverage.processing;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static tdl.datapoint.coverage.processing.Language.*;

public class LanguageTest {

    @Rule
    public ExpectedException thrown= ExpectedException.none();

    @Test
    public void should_identify_language_based_on_key() throws IllegalLanguageException {
        assertThat(Language.of("java"), is(JAVA));
    }

    @Test
    public void should_identify_language_based_on_alternative_name() throws IllegalLanguageException {
        assertThat(Language.of("js"), is(JAVASCRIPT));
        assertThat(Language.of("C#"), is(CSHARP));
    }

    @Test
    public void should_ignore_spaces_and_capitalisation_when_matching() throws IllegalLanguageException {
        assertThat(Language.of("  JaVa \n  "), is(JAVA));
    }

    @Test
    public void should_throw_exception_if_language_not_recognised() throws IllegalLanguageException {
        thrown.expect(IllegalLanguageException.class);
        Language.of("none");
    }
}