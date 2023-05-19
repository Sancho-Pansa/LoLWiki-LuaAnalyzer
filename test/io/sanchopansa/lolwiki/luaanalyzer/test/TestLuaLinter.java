package io.sanchopansa.lolwiki.luaanalyzer.test;

import io.sanchopansa.lolwiki.luaanalyzer.lualinter.LuaFunction;
import io.sanchopansa.lolwiki.luaanalyzer.lualinter.LuaLinter;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class TestLuaLinter {
    static String sourceCode;

    @BeforeAll
    static void setUp() {
        Path path = Paths.get("resources\\SkinData.lua");
        try {
            sourceCode = Files.readString(path);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    @Test
    void testLinterProcessing() {
        LuaLinter linter = new LuaLinter(sourceCode);
        assertDoesNotThrow(linter::processCode);
    }

    @Test
    void testLuaFunctionProcess() {
        LuaLinter linter = new LuaLinter(sourceCode);
        linter.processCode();
        List<LuaFunction> functionList = linter.getFunctionList();
        assertEquals("get", functionList.get(0).getName());
    }
}
