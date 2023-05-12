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
        LuaFetcher fetcher = new LuaFetcher(testModule);
        assertFalse(fetcher.getLuaCode().isEmpty());
    }
}
