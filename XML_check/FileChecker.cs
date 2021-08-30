using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Text.RegularExpressions;
using System.Xml.Schema;

namespace XML_check
{
    public class FileChecker
    {
        XDocument file;
        string workingPath;
        string[] extensions = new string[] { "xml", "xlf", "xliff", "sdlxliff", "resx" };

        public FileChecker(string workingPath)
        {
            this.workingPath = workingPath;
        }

        static void ValidationEventHandler(object sender, ValidationEventArgs e)
        {
            if (e.Severity == XmlSeverityType.Error)
            {
                throw new Exception(e.Message);
            }
        }

        public void Go()
        {
            string logName = $"xml_check_report_{DateTime.Now.ToString("yyyyMMdd_HHmmss")}.log";
            int allCounter = 0;
            int validCounter = 0;

            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine($"Working path:\r\n{ workingPath}\r\n");
            Console.WriteLine($"Included extensions:");
            foreach (string extension in extensions)
            {
                Console.WriteLine($"- { extension}");
            }
            Console.WriteLine("\r\nChecking files, please wait...\r\n");

            File.AppendAllText(logName, $"XML check report\r\n\r\n" +
                                        $"Timestamp: {DateTime.Now.ToString("yyyy.MM.dd, HH:mm")}\r\n\r\n" +
                                        $"User: {Environment.UserName}\r\n\r\n" +
                                        $"Working path:\r\n{ workingPath}\r\n\r\n" +
                                        $"List of checked files:\r\n\r\n");

            foreach (string extension in extensions)
            {
                foreach (string fileToTest in Directory.GetFiles(workingPath, $"*.{extension}", SearchOption.AllDirectories))
                {
                    allCounter++;

                    try //wellformed part
                    {
                        this.file = XDocument.Load(fileToTest);
                    }
                    catch (Exception error)
                    {
                        Console.ForegroundColor = ConsoleColor.White;
                        Console.WriteLine($"{ fileToTest.Replace(workingPath, "")} - WELL-FORMED ERROR");
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.WriteLine($"  {error.Message}\r\n");
                        File.AppendAllText(logName, $"WELL-FORMED ERROR: {fileToTest}\r\n" +
                                                    $"\t{error.Message}\r\n\r\n");
                        continue;
                    }

                    try //DTD validation part
                    {
                        XmlReaderSettings xmlReaderSettings = new XmlReaderSettings();
                        xmlReaderSettings.ValidationType = ValidationType.DTD;
                        xmlReaderSettings.DtdProcessing = DtdProcessing.Parse;
                        xmlReaderSettings.XmlResolver = new XmlUrlResolver();
                        xmlReaderSettings.ValidationEventHandler += ValidationEventHandler;
                        var reader = XmlReader.Create(fileToTest, xmlReaderSettings);
                        while (reader.Read())
                        { }
                    }
                    catch (Exception error)
                    {
                        Console.ForegroundColor = ConsoleColor.White;
                        Console.WriteLine($"{ fileToTest.Replace(workingPath, "")} - DTD VALIDATION ERROR");
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.WriteLine($"  {error.Message}\r\n");
                        File.AppendAllText(logName, $"DTD VALIDATION ERROR: {fileToTest}\r\n" +
                                                    $"\t{error.Message}\r\n\r\n");
                        continue;
                    }

                    try //XSD validation part
                    {
                        XmlReaderSettings xmlReaderSettings = new XmlReaderSettings();
                        xmlReaderSettings.ValidationType = ValidationType.Schema;
                        xmlReaderSettings.DtdProcessing = DtdProcessing.Ignore;

                        foreach (XAttribute currentAttribute in file.Root.Attributes())
                        {
                            if (Regex.IsMatch(currentAttribute.Name.LocalName, "schemaLocation"))
                            {
                                string[] schemaData = currentAttribute.Value.Split(' ');
                                foreach (string singleSchemaData in schemaData)
                                {
                                    if (singleSchemaData.EndsWith(".xsd"))
                                    {
                                        xmlReaderSettings.Schemas.Add(null, singleSchemaData);
                                    }
                                }
                            }
                        }

                        xmlReaderSettings.ValidationEventHandler += ValidationEventHandler;
                        var reader = XmlReader.Create(fileToTest, xmlReaderSettings);
                        while (reader.Read())
                        { }

                    }
                    catch (Exception error)
                    {
                        Console.ForegroundColor = ConsoleColor.White;
                        Console.WriteLine($"{ fileToTest.Replace(workingPath, "")} - XSD VALIDATION ERROR");
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.WriteLine($"  {error.Message}\r\n");
                        File.AppendAllText(logName, $"XSD VALIDATION ERROR: {fileToTest}\r\n" +
                                                    $"\t{error.Message}\r\n\r\n");
                        continue;
                    }

                    File.AppendAllText(logName, $"VALID: {fileToTest}\r\n\r\n");
                    validCounter++;

                }
            }

            Console.WriteLine("----------------\r\n" +
                             $"Total number of files:   {allCounter}\r\n" +
                             $"Number of valid files:   {validCounter}\r\n" +
                             $"Number of invalid files: {allCounter - validCounter}\r\n\r\n" +
                             $"Job's done. Press any key to quit.");

            File.AppendAllText(logName, $"Check ends here.\r\n\r\n" +
                             $"Total number of files:   { allCounter}\r\n" +
                             $"Number of valid files:   {validCounter}\r\n" +
                             $"Number of invalid files: {allCounter - validCounter}\r\n\r\n");

            Console.ReadKey();
        }
    }
}
