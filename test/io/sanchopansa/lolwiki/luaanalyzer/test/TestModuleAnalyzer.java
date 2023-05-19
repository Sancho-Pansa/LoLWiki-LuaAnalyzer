package io.sanchopansa.lolwiki.luaanalyzer.test;

import io.sanchopansa.lolwiki.luaanalyzer.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TestModuleAnalyzer {

    private final String testModule = "Модуль:SkinData";

    @BeforeEach
    void setUp() {

    }

    @Test
    void testURLFetch() {
        ModuleFetcher fetcher = new ModuleFetcher(testModule);
        assertFalse(fetcher.getLuaCode().isEmpty());
    }

    @Test
    void testLuaAnalyzer() {
        String module = "Модуль:SkinData";
        ModuleFetcher fetcher = new ModuleFetcher(module);
        ModuleAnalyzer analyzer = new ModuleAnalyzer();
        assertFalse(analyzer.analyzeLuaDependencies(fetcher.getLuaCode()).isEmpty());
    }

    @Test
    void testAllModulesFetch() {
        AllModulesFetcher fetcher = new AllModulesFetcher();
        assertFalse(fetcher.getAllModules().isEmpty());
    }
}
