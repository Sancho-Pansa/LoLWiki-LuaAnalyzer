package io.sanchopansa.lolwiki.luaanalyzer.test;

import io.sanchopansa.lolwiki.luaanalyzer.ModuleFetcher;
import io.sanchopansa.lolwiki.luaanalyzer.lualinter.LuaFunction;
import io.sanchopansa.lolwiki.luaanalyzer.lualinter.LuaLinter;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class TestLuaLinter {
    static String sourceCode;

    @BeforeAll
    static void setUp() {
        ModuleFetcher mFetcher = new ModuleFetcher("Module:SkinData");
        sourceCode = mFetcher.getLuaCode();
    }
    @Test
    void testLinterProcessing() {
        LuaLinter linter = new LuaLinter(sourceCode);
        assertDoesNotThrow(linter::processCode);
    }

    @Test
    void testLuaFunctionProcess() {
        LuaLinter linter = new LuaLinter(sourceCode);
        List<LuaFunction> functionList = linter.listAllFunctions();
        functionList.forEach(System.out::println);
        assertEquals("get", functionList.get(0).getName());
    }

    @Test
    void testDependencyList() {
        LuaLinter linter = new LuaLinter(sourceCode);
        Set<String> dependencies = linter.listAllDependencies();
        dependencies.forEach(System.out::println);
        assertTrue(dependencies.contains("Модуль:ImageLink"));
    }

    @Test
    void testFunctionSearch() {
        LuaLinter linter = new LuaLinter(sourceCode);
        List<LuaFunction> functionList = linter.listAllFunctions();
        LuaFunction func = functionList.get(1);
        assertNotEquals("", linter.getFunctionCode(func));
    }
}
