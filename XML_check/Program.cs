using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace XML_check
{
    class Program
    {
        static void Main(string[] args)
        {
            FileChecker fileChecker = new FileChecker(Directory.GetCurrentDirectory());
            fileChecker.Go();
        }
    }
}
