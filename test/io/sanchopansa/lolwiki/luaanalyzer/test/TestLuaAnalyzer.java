package io.sanchopansa.lolwiki.luaanalyzer.test;

import io.sanchopansa.lolwiki.luaanalyzer.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TestLuaAnalyzer {

    private final String testModule = "Модуль:SkinData";

    @BeforeEach
    void setUp() {

    }

    @Test
    void testURLFetch() {
        LuaModuleFetcher fetcher = new LuaModuleFetcher(testModule);
        assertFalse(fetcher.getLuaCode().isEmpty());
    }

    @Test
    void testAllModulesFetch() {
        AllModulesFetcher fetcher = new AllModulesFetcher();
        assertFalse(fetcher.getAllModules().isEmpty());
    }
}
