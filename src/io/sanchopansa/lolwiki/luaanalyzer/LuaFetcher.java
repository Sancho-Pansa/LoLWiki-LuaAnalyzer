package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Optional;

public class LuaFetcher {
    private final String API_PREFIX = "https://leagueoflegends.fandom.com/ru/api.php?action=parse&format=json&prop=wikitext&formatversion=2";
    private final String pageName;

    public LuaFetcher(String pageName) {
        this.pageName = pageName;
    }

    public String getLuaCode() {

        return null;
    }

    private BufferedReader performConnection() {
        try {
            URL url = new URL(API_PREFIX + "&page=" + pageName);

            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("GET");
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setRequestProperty("User-Agent", "Mozilla/5.0");

            int responseCode = urlConnection.getResponseCode();
            if(responseCode == HttpURLConnection.HTTP_OK) {
                InputStream is = urlConnection.getInputStream();
                return new BufferedReader(new InputStreamReader(is));
            }
        } catch(MalformedURLException e) {
            System.err.println("Incorrect URL detected");
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }
}
