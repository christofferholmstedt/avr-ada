with FATFS;
use FATFS;

package AdaDIO is

    procedure Open(Pathname : String; For_Write, Create : Boolean := False);
    procedure Read(Sector : Sector_Type; Block : out Block_512; OK : out Boolean);
    procedure Write(Sector : Sector_Type; Block : Block_512; OK : out Boolean);
    procedure Close;

end AdaDIO;
