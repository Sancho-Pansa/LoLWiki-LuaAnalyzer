package io.sanchopansa.lolwiki.luaanalyzer;

public class MainClass {
    public static void main(String[] args) {
        System.out.println(new LuaFetcher("Модуль:SkinData").getLuaCode());
    }
}
