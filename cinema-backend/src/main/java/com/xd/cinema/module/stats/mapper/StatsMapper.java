package com.xd.cinema.module.stats.mapper;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface StatsMapper {

  List<TypeCountRow> typeCount();

  List<TypeBoxOfficeRow> typeBoxOffice();

  Long countMovies();

  Long countCinemas();

  BigDecimal sumTotalBoxOffice();

  class TypeCountRow {
    public Long typeId;
    public String typeName;
    public Long cnt;
  }

  class TypeBoxOfficeRow {
    public Long typeId;
    public String typeName;
    public BigDecimal amount;
  }
}

