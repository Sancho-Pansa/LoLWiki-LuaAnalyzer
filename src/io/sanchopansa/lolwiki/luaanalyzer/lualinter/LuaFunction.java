package io.sanchopansa.lolwiki.luaanalyzer.lualinter;

public class LuaFunction {
    private String parentTable;
    private String name;
    private String[] arguments;

    public LuaFunction() {

    }

    public String getName() {
        return name;
    }

    public String getParentTable() {
        return parentTable;
    }

    public String[] getArguments() {
        return arguments;
    }

    @Override
    public String toString() {
        StringBuilder sBuilder = new StringBuilder("{LuaFunction}:[\"");
        if(!this.parentTable.equals(""))
            sBuilder.append(parentTable).append(".");
        sBuilder.append(this.name.equals("") ? "(Anonymous Function)" : this.name);
        if(this.arguments.length != 0) {
            sBuilder
                    .append("(")
                    .append(String.join(", ", this.arguments))
                    .append(")");
        }
        sBuilder.append("\"]");
        return sBuilder.toString();
    }

    public static class LuaFunctionBuilder {
        private final LuaFunction newFunction = new LuaFunction();
        public LuaFunctionBuilder() {

        }

        public LuaFunctionBuilder name(String name) {
            newFunction.name = name;
            return this;
        }

        public LuaFunctionBuilder parentTable(String tableName) {
            newFunction.parentTable = tableName;
            return this;
        }

        public LuaFunctionBuilder arguments(String[] args) {
            newFunction.arguments = args;
            return this;
        }

        public LuaFunction build() {
            if(newFunction.name == null)
                newFunction.name = "";
            if(newFunction.parentTable == null)
                newFunction.parentTable = "_G";
            if(newFunction.arguments == null)
                newFunction.arguments = new String[]{};
            return this.newFunction;
        }
    }

}