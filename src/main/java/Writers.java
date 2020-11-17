import java.sql.*;
import java.util.ArrayList;

public class Writers {

    private Connection connect = null;
    private Statement statement = null;
    private PreparedStatement preparedStatement = null;
    private ResultSet resultSet = null;

    private static ArrayList<ArrayList<String>> results = new ArrayList<ArrayList<String>>();

    private static final String url = "jdbc:mysql://localhost:3306/Practicum2";
    private static final String user = "root";
    private static final String pass = "5DL5oYhn5a2G";

    private static String result;
    private static int mediaIndex;

    public void insertIntoWriters(String titleID, String personID) {

        try {
            connect = DriverManager.getConnection(url, user, pass);
            statement = connect.createStatement();

            preparedStatement = connect.prepareStatement("INSERT INTO writers(titleID, personID) " +
                    "VALUES (?, ?)");

            preparedStatement.setString(1, titleID);
            preparedStatement.setString(2, personID);

            preparedStatement.executeUpdate();
            connect.close();

        } catch (Exception e) {
            System.err.println(e.getMessage());
        } finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (connect != null) {
                try {
                    connect.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public int read() {
        try {
            connect = DriverManager.getConnection(url, user, pass);
            statement = connect.createStatement();

            String statement = "SELECT C.tconst, C.writers " +
                    "FROM crew_tsv AS C";
            PreparedStatement preparedStatement = connect.prepareStatement(statement);
            resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                ArrayList<String> helper = new ArrayList<String>();
                for(int i = 1; i <= 2; i++){
                    helper.add(resultSet.getString(i));
                }
                results.add(helper);
            }

        } catch (Exception e) {
            System.err.println(e.getMessage());
        } finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (connect != null) {
                try {
                    connect.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return 0;
    }

    public static void main(String[] arg) throws Exception {

        Writers writers = new Writers();
        writers.read();
        for(ArrayList<String> value: results){
            if (value.get(1) == null)
            {
                continue;
            }
            if(value.get(1).indexOf(',') != -1){
                String[] helper = value.get(1).split(",");
                for(String secondary: helper){
                    writers.insertIntoWriters(value.get(0), secondary);
                }
            }
            else{
                writers.insertIntoWriters(value.get(0), value.get(1));
            }
        }

    }
}
