package io.sanchopansa.lolwiki.luaanalyzer.test;

import io.sanchopansa.lolwiki.luaanalyzer.*;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.*;

public class TestLuaLinter {
    static String sourceCode;

    @BeforeAll
    static void setUp() {
        Path path = Paths.get("resources\\SkinData.lua");
        try {
            sourceCode =  Files.readString(path);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    @Test
    void testURLFetch() {
        LuaLinter linter = new LuaLinter(sourceCode);
        assertFalse(linter.getCodeStructure().isEmpty());
    }
}
