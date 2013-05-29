///<reference path='../../ts-definitions/DefinitelyTyped/express/express.d.ts'/>

interface Division {
  house: string;
  date: Date;
  time: Date;
  subject: string;
  turnout: number;
  majority: number;
}

export class Divisions {
  static index(req, res, next) {
    var division: Division = {
       house: 'Reps',
       date: new Date,
       time: new Date,
       subject: 'Growth',
       turnout: 100,
       majority: 20
    }
    res.send([division])
  }
}
